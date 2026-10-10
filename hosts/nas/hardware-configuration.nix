# PLACEHOLDER until the machine arrives. Replace this file with the output of
#   nixos-generate-config --show-hardware-config
# run on the NAS, and mount the data disk on /data (see README.md).
{
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd"];
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
}
