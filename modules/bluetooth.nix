{ pkgs, ... }:

{
  # Enable Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket"; # Better audio support
        AutoConnect = true;
        ControllerMode = "dual"; # Supports both BR/EDR and LE
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
