{ pkgs, ... }:

{
  # Enable Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Enbles Battery status for some devices
      };
    };
  };

  # Enable blueman for tray applet and management
  services.blueman.enable = true;

  # Add blueman-applet to system packages to ensure it's available
  environment.systemPackages = with pkgs; [
    blueman
  ];
}
