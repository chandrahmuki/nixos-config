{den, ...}: {
  den.aspects.qmk.nixos = {pkgs, ...}: {
    # udev rules so a keyboard in bootloader mode can be flashed without root.
    hardware.keyboard.qmk.enable = true;

    environment.systemPackages = [
      # The qmk CLI bundles the AVR and ARM toolchains, dfu-programmer and avrdude.
      pkgs.qmk
      pkgs.dfu-util
    ];
  };
}
