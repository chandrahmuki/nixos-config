{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    home.packages = [
          pkgs.microfetch
        ];
  };
}
