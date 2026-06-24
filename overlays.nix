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
      antigravity-cli = inputs.self.packages.${final.stdenv.hostPlatform.system}.antigravity-cli;
    })
  ];
}
