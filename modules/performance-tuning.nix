{ lib, ... }:

{
  # --- PERFORMANCE TUNING (performance-engineer skill) ---

  # 1. Memory Management (ZRAM + Optimized Swappiness)
  # When using ZRAM, we want the kernel to be more aggressive in swapping out
  # anonymous memory to compressed RAM before hitting the actual disk.
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0; # Reduce latency spikes during memory pressure
    "vm.vfs_cache_pressure" = 50; # Keep inode/dentry cache longer
    "vm.dirty_bytes" = 268435456; # 256MB dirty limit
    "vm.dirty_background_bytes" = 67108864; # 64MB background dirty limit
  };

  # 2. Transparent Huge Pages (THP) & GPU Optimizations
  # Forces THP to 'always' for applications to reduce TLB misses.
  # Best for high RAM systems (64GB+).
  boot.kernelParams = [ 
    "transparent_hugepage=always" 
    "amdgpu.gttsize=16384"
  ];

  # 3. Network Optimizations
  # Optimized for stability and low latency.
  # fq_codel is preferred for David's setup to keep CPU usage low during high-speed downloads.
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "cubic";
    "net.ipv4.tcp_fastopen" = 3; # Enable TCP Fast Open (client and server)
    "net.ipv4.tcp_slow_start_after_idle" = 0; # Don't reset congestion window after idle
  };

  # 4. AMD GPU & Kernel Features
  # ntsync for Proton/Wine performance
  boot.kernelModules = [ "ntsync" ];
}
