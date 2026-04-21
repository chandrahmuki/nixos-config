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
      deno = prev.deno.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
