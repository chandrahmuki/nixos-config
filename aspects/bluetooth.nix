{den, ...}: {
  den.aspects.bluetooth.nixos = {pkgs, ...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket";
        AutoConnect = true;
        ControllerMode = "dual";
      };
    };
    services.blueman.enable = true;
    environment.systemPackages = [pkgs.blueman];
  };

  den.aspects.muggy-nixos.includes = [den.aspects.bluetooth];
}
