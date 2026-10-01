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

    # Disable USB autosuspend on the CSR8510 Bluetooth dongle: with autosuspend
    # left on "auto" the kernel suspends it and the wake-up latency drops the
    # link mid-call (Teams, TTS mic capture). Target this device only.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0a12", ATTR{idProduct}=="0001", TEST=="power/control", ATTR{power/control}="on"
    '';
  };
}
