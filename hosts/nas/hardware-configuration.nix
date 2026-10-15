# Generated on the NAS (AOOSTAR WTR PRO, Ryzen 7 5825U) with
#   nixos-generate-config --root /mnt --show-hardware-config
# then given the same btrfs options as the desktop. System on the 500 GB SATA SSD
# (sda); /data is the empty ext4 partition of the 2 TB disk for now (README.md).
{
  config,
  lib,
  modulesPath,
  ...
}: let
  system = "/dev/disk/by-uuid/993f231c-2d68-4783-b34c-7d117fbd2528";
  btrfsOptions = subvol: ["subvol=${subvol}" "compress=zstd:3" "noatime"];
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # nvme is not used yet: the two M.2 slots are empty.
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "uas" "usbhid" "sd_mod" "nvme"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" = {
    device = system;
    fsType = "btrfs";
    options = btrfsOptions "@";
  };

  fileSystems."/nix" = {
    device = system;
    fsType = "btrfs";
    options = btrfsOptions "@nix";
  };

  fileSystems."/var/log" = {
    device = system;
    fsType = "btrfs";
    options = btrfsOptions "@log";
  };

  fileSystems."/home" = {
    device = system;
    fsType = "btrfs";
    options = btrfsOptions "@home";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9A28-7CA5";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  # Data disk: the machine still boots if it is missing, the services just have no data.
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/25b22549-e204-4754-9802-cdbf1d56258e";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=10s"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = "x86_64-linux";
}
