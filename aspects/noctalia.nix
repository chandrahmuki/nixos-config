{
  den,
  inputs,
  ...
}: {
  den.aspects.noctalia.homeManager = {
    user,
    config,
    ...
  }: {
    imports = [inputs.noctalia.homeModules.default];
    home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
      defaultWallpaper = "/home/${user.userName}/Pictures/wallpaper/wallpaper.png";
    };
    programs.noctalia = {
      enable = true;
      systemd.enable = false;
    };
    home.sessionVariables.NOCTALIA_SETTINGS_FILE = "${config.xdg.configHome}/noctalia/settings.json";
  };

  den.aspects.david.includes = [den.aspects.noctalia];
}
