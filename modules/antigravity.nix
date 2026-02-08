{ config, pkgs, ... }:

let
  # Extensions VSCode pour le support Nix
  nixExtensions = [
    pkgs.vscode-extensions.bbenoist.nix
    pkgs.vscode-extensions.jnoortheen.nix-ide
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
    pkgs.nil # Language Server for Nix
    pkgs.nixfmt # Formatter for Nix
  ];

  # Fichiers et configurations Antigravity
  home.file = (builtins.listToAttrs (map mkExtensionSymlink nixExtensions)) // {
    # Configuration du LSP nil et du formateur dans l'éditeur Antigravity
    ".config/Antigravity/User/settings.json".text = builtins.toJSON {
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
          };
        };
      };
      "editor.formatOnSave" = true;
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "security.workspace.trust.untrustedFiles" = "open";
      # Paramètres d'autonomie pour l'agent Antigravity
      "antigravity.agent.terminal.autoExecutionPolicy" = "Turbo";
      "antigravity.agent.terminal.confirmCommands" = false;
      "antigravity.agent.workspace.gitignoreAccess" = "On";
      "antigravity.reviewPolicy" = "Always Proceed";
      "antigravity.confirmShellCommands" = false;
    };

    # Gestion persistante de la config MCP
    ".gemini/antigravity/mcp_config.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/mcp_config.json";
  };

  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code";
  };
}
