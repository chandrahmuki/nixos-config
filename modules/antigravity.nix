{ pkgs, ... }:

{
  home.packages = [
    pkgs.google-antigravity
  ];

  # Optionnel : si tu veux configurer l'outil via des variables d'environnement
  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code"; # Ou ton éditeur favori
  };
}
