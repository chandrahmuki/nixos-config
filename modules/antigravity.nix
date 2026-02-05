{ pkgs, ... }:

{
  home.packages = [
    pkgs.google-antigravity
  ];

  # Optionnel : si tu veux configurer l'outil via des variables d'environnement
  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code"; # Ou ton éditeur favori
  };
  # Note: mcp_config.json n'est pas géré ici pour le moment car il contient
  # des secrets (GitHub PAT). Pour la reproductibilité, utiliser sops-nix ou
  # garder le fichier localement dans ~/.gemini/antigravity/mcp_config.json
  # SANS l'ajouter au dépôt Git.
}
