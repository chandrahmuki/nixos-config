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
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    })
    (final: prev: {
      parsec-bin = prev.parsec-bin.overrideAttrs (old: {
        version = "150-103a";
        src = final.fetchurl {
          url = "https://builds.parsec.app/package/parsec-linux.deb";
          hash = "sha256-8Wkbo6l1NGBPX2QMJszq+u9nLM96tu7WYRTQq6/CzM8=";
        };
      });
    })
  ];
}
