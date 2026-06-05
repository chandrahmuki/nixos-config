{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });

      antigravity-cli = inputs.self.packages.${final.system}.antigravity-cli;
    })
  ];
}
