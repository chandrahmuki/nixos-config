{ pkgs, hostname, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=18";
        pad = "15x15";
      };
      colors = {
        foreground = "c0caf5";
        background = "1a1b26";

        ## Normal/regular colors (color palette 0-7)
        regular0 = "15161e"; # black
        regular1 = "f7768e"; # red
        regular2 = "9ece6a"; # green
        regular3 = "e0af68"; # yellow
        regular4 = "7aa2f7"; # blue
        regular5 = "bb9af7"; # magenta
        regular6 = "7dcfff"; # cyan
        regular7 = "a9b1d6"; # white

        ## Bright colors (color palette 8-15)
        bright0 = "414868"; # bright black
        bright1 = "f7768e"; # bright red
        bright2 = "9ece6a"; # bright green
        bright3 = "e0af68"; # bright yellow
        bright4 = "7aa2f7"; # bright blue
        bright5 = "bb9af7"; # bright magenta
        bright6 = "7dcfff"; # bright cyan
        bright7 = "c0caf5"; # bright white

        ## dimmed colors
        dim0 = "ff9e64";
        dim1 = "db4b4b";
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

      # Chargement dynamique des clés API depuis sops-nix
      # home.sessionVariables ne supporte pas $(cat ...) avec Fish (traité littéralement)
      set -l _key_file ~/.config/antigravity/gemini_api_key
      if test -f $_key_file
        set -gx GEMINI_API_KEY (cat $_key_file)
        set -gx GOOGLE_API_KEY (cat $_key_file)
      end

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
      nix-switch = "sudo nixos-rebuild switch --flake .#${hostname}";
    };

  };
}
