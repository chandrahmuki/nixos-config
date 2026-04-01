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
      yt-dlp = inputs.nixpkgs-master.legacyPackages.${final.stdenv.hostPlatform.system}.yt-dlp;
    })
  ];
}
