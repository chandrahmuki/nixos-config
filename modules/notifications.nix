{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      home.packages = [ pkgs.libnotify ];

      services.mako = {
        enable = true;
      };

      home.file.".config/mako/config".source =
        config.lib.file.mkOutOfStoreSymlink "/home/${username}/nixos-config/generated/mako";
    };
}
