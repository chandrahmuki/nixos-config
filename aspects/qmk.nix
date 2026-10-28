{den, ...}: {
  den.aspects.qmk.nixos = {
    pkgs,
    inputs,
    ...
  }: {
    # udev rules so a keyboard in bootloader mode can be flashed without root.
    hardware.keyboard.qmk.enable = true;

    environment.systemPackages = [
      # The qmk CLI bundles the AVR and ARM toolchains, dfu-programmer and avrdude. It comes
      # from the older pin of nixpkgs-immich on purpose: with the current nixpkgs and master
      # the ARM toolchain (gcc-arm-embedded 15.3) segfaults on every binary (gcc, as, ld),
      # while this pin's build runs. Go back to pkgs.qmk once that is fixed upstream.
      inputs.nixpkgs-immich.legacyPackages.${pkgs.stdenv.hostPlatform.system}.qmk
      pkgs.dfu-util
    ];
  };
}
