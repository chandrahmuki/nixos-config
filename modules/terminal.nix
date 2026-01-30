{ pkgs, ... }:

{
  # On garde foot dans les paquets, mais on le configure via son propre module
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font:size=18";
        pad = "15x15";
      };
      colors = {
        # Un joli thème sombre (Tokyo Night)
        background = "1a1b26";
        foreground = "c0caf5";
      };
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
    '';
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake .#muggy-nix-desktop";
    };
  };
}
