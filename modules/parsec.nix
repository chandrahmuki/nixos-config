{ config, lib, pkgs, username, ... }:
{
  home-manager.users.${username} = { lib, pkgs, ... }: {
    home.sessionVariables = {
      ELECTRON_ENABLE_WAYLAND = "0";
      GDK_BACKEND = "x11";
    };
    home.packages = [ pkgs.parsec-bin ];
  };
}
