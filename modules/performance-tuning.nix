{ config, lib, pkgs, ... }:

{
  # --- PERFORMANCE TUNING (performance-engineer skill) ---

  # 1. Memory Management (ZRAM + Optimized Swappiness)
  # When using ZRAM, we want the kernel to be more aggressive in swapping out
  # anonymous memory to compressed RAM before hitting the actual disk.
  boot.kernel.sysctl = {
    # Memory Management
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 67108864;
    # Network Optimizations
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "cubic";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };

  # 2. Transparent Huge Pages (THP) & GPU Optimizations
  boot.kernelParams = [
    "transparent_hugepage=always"
    "amdgpu.gttsize=16384"
  ];

  # 4. AMD GPU & Kernel Features
  # ntsync for Proton/Wine performance
  boot.kernelModules = [ "ntsync" ];

  # Hardware acceleration (VA-API)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
      mesa
      rocmPackages.clr.icd # OpenCL pour AMD
    ];
  };
  
  # Forcer VA-API sur radeonsi pour AMD
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };
}
