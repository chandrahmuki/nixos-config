{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      home.packages = with pkgs; [
        nixfmt
        nil
      ];

      programs.vscode = {
        enable = true;

        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
            bbenoist.nix
            jnoortheen.nix-ide
            dracula-theme.theme-dracula
            christian-kohler.path-intellisense
          ];

          userSettings = {
            "editor.fontFamily" = "'Hack Nerd Font', 'monospace'";
            "editor.fontSize" = 16;
            "workbench.colorTheme" = "Dracula";
            "terminal.integrated.fontFamily" = "Hack Nerd Font";
            "window.titleBarStyle" = "custom";

            "path-intellisense.mappings" = {
              "./" = "\${workspaceRoot}";
            };

            "editor.formatOnSave" = true;
            "[nix]" = {
              "editor.defaultFormatter" = "jnoortheen.nix-ide";
            };

            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "${pkgs.nil}/bin/nil";
            "nix.serverSettings" = {
              "nil" = {
                "formatting" = {
                  "command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
                };
                "diagnostics" = {
                  "ignored" = [ ];
                };
                "nix" = {
                  "flake" = {
                    "autoArchive" = true;
                    "autoEvalInputs" = true;
                  };
                };
              };
            };
          };
        };
      };
    };
}
