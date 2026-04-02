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

    # Allow home-manager to overwrite config files without backups
    xdg.configFile."btop/btop.conf".force = true;
  };
}
