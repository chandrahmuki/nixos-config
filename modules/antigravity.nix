{ pkgs, ... }:

{
  home.packages = [
    pkgs.google-antigravity
  ];

  # Optionnel : si tu veux configurer l'outil via des variables d'environnement
  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code"; # Ou ton éditeur favori
  };
  # Gestion persistante de la config MCP (liant le fichier ignoré par Git au Home)
  home.file.".gemini/antigravity/mcp_config.json".source = ./mcp_config.json;
}
