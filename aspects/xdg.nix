{den, ...}: {
  den.aspects.xdg.homeManager = {
    user,
    config,
    ...
  }: {
    xdg = {
      enable = true;
      mimeApps.enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        documents = "/home/${user.userName}/Documents";
        download = "/home/${user.userName}/Downloads";
        music = "/home/${user.userName}/Music";
        pictures = "/home/${user.userName}/Pictures";
        videos = "/home/${user.userName}/Videos";
        desktop = "/home/${user.userName}/Desktop";
        publicShare = "/home/${user.userName}/Public";
        templates = "/home/${user.userName}/Templates";
      };
    };
    home.file = {
      "Games".source = config.lib.file.mkOutOfStoreSymlink "/mnt/games";
      "Storage".source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage";
      "backups".source = config.lib.file.mkOutOfStoreSymlink "/mnt/backup";
    };
  };

  den.aspects.david.includes = [den.aspects.xdg];
}
