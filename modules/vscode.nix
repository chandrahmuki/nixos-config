{ pkgs, ... }:

{
  # On installe les outils nécessaires au fonctionnement de l'IDE
  home.packages = with pkgs; [
    nixfmt # Le formateur officiel
    nil              # Le "cerveau" (Language Server) pour Nix
  ];

  programs.vscode = {
    enable = true;
    
  profiles.default = {
    # Extensions installées et gérées par Nix
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix                # Coloration syntaxique
      jnoortheen.nix-ide          # Support IDE (LSP)
      dracula-theme.theme-dracula      # Thème visuel
    ];

    # Configuration de l'éditeur
    userSettings = {
      # Apparence et Police
      "editor.fontFamily" = "'Hack Nerd Font', 'monospace'";
      "editor.fontSize" = 16;
      "workbench.colorTheme" = "Dracula";
      "terminal.integrated.fontFamily" = "Hack Nerd Font";
      "window.titleBarStyle" = "custom";

      # Automatisation du formatage (nixfmt)
      "editor.formatOnSave" = true;
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };

      # Configuration du support Nix (LSP nil)
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = { "command" = [ "nixfmt" ]; };
        };
      };
    };
  };
 };
}
