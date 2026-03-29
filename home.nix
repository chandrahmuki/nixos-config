{ username, hostname, config, pkgs, ... }: # <-- N'oublie pas d'ajouter { config, pkgs, ... }: en haut !

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  # Les imports sont désormais gérés de manière Dendritic via le système
  imports = [
  ];

  programs.home-manager.enable = true;

  # Silencing Home Manager 26.05 warnings by keeping legacy behavior
  gtk.gtk4.theme = config.gtk.theme;
  xdg.userDirs.setSessionVariables = true;
}
