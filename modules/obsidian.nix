{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    programs.obsidian = {
          enable = true;
        };
  };
}
