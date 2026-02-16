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

      # Raccourcis Zoom
      keybind = [
        "ctrl+plus=increase_font_size:1"
        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+0=reset_font_size"

        # User request: Shift+Alt+Wheel
        # Note: Mouse binding support in Ghostty is experimental/limited.
        # If wheel doesn't work, use the Shift+Alt+Plus/Minus shortcuts below.
        "shift+alt+plus=increase_font_size:1"
        "shift+alt+minus=decrease_font_size:1"
      ];
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

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  # Configuration de FISH
  programs.fish = {
    enable = true;
    # Ton shell sera tout de suite prêt à l'emploi
    interactiveShellInit = ''
      set -g fish_greeting ""

      if status is-interactive
        # Fonction pour les outils visuels (Starship, Fastfetch)
        # On les regroupe pour plus de clarté
        function setup_visual_tools
          starship init fish | source
          atuin init fish | source
        end

        # On ne lance les outils visuels que si on n'est pas dans un terminal "dumb"
        # Cela évite de bloquer l'agent AI ou les commandes distantes
        if test "$TERM" != "dumb"
          setup_visual_tools
        end

        # Mode Vim pour Fish
        fish_vi_key_bindings
        
        # Configuration du curseur pour les modes Vi (premium touch)
        set -g fish_cursor_default block
        set -g fish_cursor_insert line
        set -g fish_cursor_replace_one underscore
        set -g fish_cursor_visual block

        # Raccourci jk pour sortir du mode insertion (Esc)
        function fish_user_key_bindings
          bind -M insert -m default jk backward-char force-repaint
        end

        # Complétion pour nfu (nix flake update)
        # On extrait les inputs du flake.lock et on exclut ceux déjà présents sur la ligne de commande
        complete -c nfu -f -a "(
          if test -f flake.lock
            set -l inputs (cat flake.lock | jq -r '.nodes.root.inputs | keys[]' 2>/dev/null)
            set -l current_args (commandline -opc)
            for i in \$inputs
              if not contains \$i \$current_args
                echo \$i
              end
            end
          end
        )"
      end
    '';
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake .#muggy-nixos";
    };

  };
}
