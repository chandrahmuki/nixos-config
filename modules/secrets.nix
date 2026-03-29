{ config, lib, pkgs, username, inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  home-manager.users.${username} = { config, lib, ... }: {
    imports = [
          inputs.sops-nix.homeManagerModules.sops
        ];

        sops = {
          # Point vers le fichier de secrets chiffré dans ton dépôt
          defaultSopsFile = ../secrets/secrets.yaml;

          # Utilise ta clé SSH pour déchiffrer
          age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];

          secrets = {
            # Le secret sera déchiffré dans ~/.config/sops/github_token
            github_token = {
              path = "/home/${username}/.config/sops/github_token";
            };

            # Clé API Gemini pour Gemini CLI
            gemini_api_key = {
              path = "/home/${username}/.config/sops/gemini_api_key";
            };
          };
        };
  };
}
