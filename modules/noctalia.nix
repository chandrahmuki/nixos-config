{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  home-manager.users.${username} =
    { config, lib, ... }:
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
        defaultWallpaper = "/home/${username}/Pictures/wallpaper/wallpaper.png";
      };

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = false;
      };

      home.sessionVariables = {
        NOCTALIA_SETTINGS_FILE = "/home/${username}/nixos-config/generated/noctalia-settings.json";
      };
    };
}
