{ config, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # Point vers le fichier de secrets chiffré dans ton dépôt
    defaultSopsFile = ../secrets/secrets.yaml;
    
    # Utilise ta clé SSH pour déchiffrer
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    
    secrets = {
      # Le secret sera déchiffré dans /run/user/1000/secrets/github_token
      github_token = {
        path = "${config.home.homeDirectory}/.config/antigravity/github_token";
      };
      
      # Clé API Gemini pour Antigravity et Gemini CLI
      gemini_api_key = {
        path = "${config.home.homeDirectory}/.config/antigravity/gemini_api_key";
      };
      
      # Si tu as besoin d'un token Atlassian aussi, on peut le rajouter ici
      # atlassian_token = {};
    };
  };
}
