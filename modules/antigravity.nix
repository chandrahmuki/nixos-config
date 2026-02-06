{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.google-antigravity
    pkgs.nil    # Language Server for Nix
    pkgs.nixfmt # Formatter for Nix
  ];

  # Optionnel : si tu veux configurer l'outil via des variables d'environnement
  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code"; # Ou ton éditeur favori
  };
  # Gestion persistante de la config MCP (liant le fichier ignoré par Git au Home)
  # On utilise mkOutOfStoreSymlink car le fichier est ignoré par Git et Nix Flake ne le voit pas sinon.
  home.file.".gemini/antigravity/mcp_config.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/david/nixos-config/modules/mcp_config.json";
}
