{den, ...}: {
  den.aspects.xdg.homeManager = {
    user,
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
  };

}
