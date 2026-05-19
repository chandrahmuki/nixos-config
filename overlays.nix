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

      antigravity-cli = final.stdenvNoCC.mkDerivation {
        name = "antigravity-cli-1.0.0";
        src = final.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.0-5288553236791296/linux-x64/cli_linux_x64.tar.gz";
          sha512 = "5ccdcc01fb863c7e8e56473c6c95dba75fed4fd2a242200d80cfc4c7fab811b733f5a7fab25332130aad298e72627e1018e6911a5658f4f059ef6e019f211972";
        };
        sourceRoot = ".";
        installPhase = ''
          install -m755 -D antigravity $out/bin/agy
        '';
      };
    })
  ];
}
