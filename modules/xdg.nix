{ config, pkgs, ... }:

{
  # Gestion des répertoires utilisateurs standards (Documents, Images, etc.)
  xdg.userDirs = {
    enable = true;
    createDirectories = true; # Crée les dossiers s'ils n'existent pas
    
    # Chemins par défaut
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    desktop = "${config.home.homeDirectory}/Desktop";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
  };

  # On peut aussi s'assurer que XDG lui-même est bien là (souvent implicite mais bon à avoir)
  xdg.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
    };
  };
}
