{
  username,
  hostname,
  config,
  pkgs,
  lib,
  ...
}:
# <-- N'oublie pas d'ajouter { config, pkgs, ... }: en haut !
{
  # Informations sur le profil utilisateur et son dossier personnel
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Version initiale de l'état Home Manager (ne pas modifier)
  home.stateVersion = "25.11";

  # Les imports d'autres modules utilisateur sont gérés de manière dynamique dans flake.nix
  imports = [
  ];

  # Activer la gestion de Home Manager par lui-même
  programs.home-manager.enable = true;

  # Silencing Home Manager 26.05 warnings by keeping legacy behavior
  # Thémage GTK4 reprenant la configuration GTK globale
  gtk.gtk4.theme = lib.mkDefault config.gtk.theme;

  # Exportation des variables de répertoires XDG par défaut (Downloads, Music, etc.) dans la session
  xdg.userDirs.setSessionVariables = true;
}
