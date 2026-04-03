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
      # deno 2.7.9 a des tests TTY cassés sur nixpkgs-unstable et master
      deno = prev.deno.overrideAttrs (_: { doCheck = false; });
    })
  ];
}
