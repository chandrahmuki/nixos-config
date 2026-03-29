{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    # Gestion des répertoires utilisateurs standards (Documents, Images, etc.)
        xdg.userDirs = {
          enable = true;
          createDirectories = true; # Crée les dossiers s'ils n'existent pas

          # Chemins par défaut
          documents = "/home/${username}/Documents";
          download = "/home/${username}/Downloads";
          music = "/home/${username}/Music";
          pictures = "/home/${username}/Pictures";
          videos = "/home/${username}/Videos";
          desktop = "/home/${username}/Desktop";
          publicShare = "/home/${username}/Public";
          templates = "/home/${username}/Templates";
        };

        # Symlinks vers les disques de données
        home.file."Games".source = config.lib.file.mkOutOfStoreSymlink "/home/${username}/.local/share/Steam/steamapps";
        home.file."Storage".source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage";

        # On peut aussi s'assurer que XDG lui-même est bien là (souvent implicite mais bon à avoir)
        xdg.enable = true;

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = "com.brave.Browser.desktop";
            "x-scheme-handler/http" = "com.brave.Browser.desktop";
            "x-scheme-handler/https" = "com.brave.Browser.desktop";
          };
        };
  };
}
