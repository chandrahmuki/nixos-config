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
    inputs.opencode.overlays.default
    (final: prev: {
      deno = prev.deno.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
