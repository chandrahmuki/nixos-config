{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}: {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
      defaultWallpaper = "/home/${username}/Pictures/wallpaper/wallpaper.png";
    };

    programs.noctalia = {
      enable = true;
      systemd.enable = false;
    };

    home.sessionVariables = {
      NOCTALIA_SETTINGS_FILE = "${config.xdg.configHome}/noctalia/settings.json";
    };
  };
}
