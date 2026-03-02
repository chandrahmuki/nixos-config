{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
    (final: prev: {
      google-antigravity = final.callPackage ./pkgs/google-antigravity { };
      muggy = final.callPackage ./pkgs/muggy { };
    })
  ];
}
