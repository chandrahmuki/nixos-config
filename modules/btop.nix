{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "dracula";
        vim_keys = true;
      };
    };
  };
}
