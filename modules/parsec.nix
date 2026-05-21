{ config, lib, pkgs, username, ... }:
{
  home-manager.users.${username} = { lib, pkgs, ... }: {
    home.sessionVariables = {
      ELECTRON_ENABLE_WAYLAND = "0";
    };
    home.packages = [
      (pkgs.symlinkJoin {
        name = "parsec-wrapped";
        paths = [ pkgs.parsec-bin ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/parsecd \
            --set GDK_BACKEND x11
        '';
      })
    ];
  };
}
