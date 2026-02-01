{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "Dracula";
      font-family = "Hack Nerd Font";
      font-size = 18;
      background-opacity = 0.9;
      window-padding-x = 15;
      window-padding-y = 15;
      window-decoration = false;
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true; # Crée automatiquement les alias ls, ll, etc.
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
  # On active Starship
  programs.starship = {
    enable = true;
    # On peut le configurer ici, mais les réglages par défaut sont déjà top
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      # Affiche une icône NixOS quand tu es dans un shell Nix
      nix_shell = {
        symbol = "❄️ ";
      };
    };
  };

  # Configuration de FISH
  programs.fish = {
    enable = true;
    # On installe les plugins ici
    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
    ];
    # Ton shell sera tout de suite prêt à l'emploi
    interactiveShellInit = ''
      fastfetch
      starship init fish | source
      set -g fish_greeting ""
    '';
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake .#muggy-nixos";
    };

  };
}
