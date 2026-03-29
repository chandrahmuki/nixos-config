{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: 
    let
      # Extensions VSCode pour le support Nix
      nixExtensions = [
        pkgs.vscode-extensions.bbenoist.nix
        pkgs.vscode-extensions.jnoortheen.nix-ide
        pkgs.vscode-extensions.enkia.tokyo-night
      ];

      # Helper pour créer les liens symboliques d'extensions dans le dossier Antigravity
      mkExtensionSymlink = ext: {
        # Format attendu par Antigravity : publisher.name-version-platform
        name = ".antigravity/extensions/${ext.vscodeExtPublisher}.${ext.vscodeExtName}-${ext.version}-universal";
        value = {
          source = "${ext}/share/vscode/extensions/${ext.vscodeExtPublisher}.${ext.vscodeExtName}";
        };
      };
    in
    {
      home.packages = [
        pkgs.google-antigravity
        pkgs.nixd # Language Server for Nix
        pkgs.nixfmt # Formatter for Nix
        pkgs.sops # Tool for managing secrets
      ];

      # Fichiers et configurations Antigravity
      home.file = (builtins.listToAttrs (map mkExtensionSymlink nixExtensions)) // {
        # Gestion persistante de la config MCP
        ".gemini/antigravity/mcp_config.json".source =
          config.lib.file.mkOutOfStoreSymlink "/home/${username}/nixos-config/.agent/mcp_config.json";

        # Script utilitaire pour mettre à jour la clé Gemini et relancer la config
        ".local/bin/update-gemini-key".source = pkgs.writeShellScript "update-gemini-key" ''
          if [ -z "$1" ]; then
            echo "Usage: update-gemini-key <TA_CLE_API>"
            exit 1
          fi
          echo "Updating Gemini API Key in sops..."
          sops --set "[\"gemini_api_key\"] \"$1\"" ~/nixos-config/secrets/secrets.yaml
          echo "Applying configuration with nos..."
          nos
        '';
      };

      # Activation Script : Force Brute pour le settings.json
      home.activation.linkAntigravitySettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run mkdir -p $HOME/.config/Antigravity/User
        run rm -f $HOME/.config/Antigravity/User/settings.json
        run ln -sf $HOME/nixos-config/.agent/antigravity-settings.json $HOME/.config/Antigravity/User/settings.json
      '';

      home.sessionVariables = {
        ANTIGRAVITY_EDITOR = "code";
      };
    };
}
