{den, ...}: {
  den.aspects.vscode.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      home.packages = with pkgs; [
        alejandra
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
            "editor.fontSize" = lib.mkForce 16;
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
                  "command" = ["${pkgs.alejandra}/bin/alejandra"];
                };
                "diagnostics" = {
                  "ignored" = [];
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
  };

}
