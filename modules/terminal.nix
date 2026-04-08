let
  colors = (import ../lib/colors.nix).tokyonight;
in
{
  config,
  lib,
  pkgs,
  username,
  hostname,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      xdg.configFile."foot/foot.ini".force = true;
      xdg.configFile."gtk-4.0/gtk.css".force = true;

      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "JetBrainsMono Nerd Font:size=18";
            pad = "15x15";
          };
          colors-dark = {
            foreground = colors.fg;
            background = colors.bg;

            regular0 = colors.dark;
            regular1 = colors.red;
            regular2 = colors.green;
            regular3 = colors.yellow;
            regular4 = colors.blue;
            regular5 = colors.magenta;
            regular6 = colors.cyan;
            regular7 = "a9b1d6";

            bright0 = colors.selection;
            bright1 = colors.red;
            bright2 = colors.green;
            bright3 = colors.yellow;
            bright4 = colors.blue;
            bright5 = colors.magenta;
            bright6 = colors.cyan;
            bright7 = colors.fg;

            dim0 = colors.orange;
            dim1 = "db4b4b";
          };
        };
      };

      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        icons = "auto";
        git = true;
        extraOptions = [
          "--group-directories-first"
          "--header"
        ];
      };

      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
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

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set -g fish_greeting ""

          function tx
              foot -f "JetBrainsMono Nerd Font:size=10" fish -c "tmux attach || tmux new-session" &
              disown
          end

          set -l _key_file ~/.config/sops/gemini_api_key
          if test -f $_key_file
            set -gx GEMINI_API_KEY (cat $_key_file)
            set -gx GOOGLE_API_KEY (cat $_key_file)
          end

          set -l _gh_token_file ~/.config/sops/github_token
          if test -f $_gh_token_file
            set -gx GITHUB_TOKEN (cat $_gh_token_file)
          end

          if status is-interactive
            function setup_visual_tools
              starship init fish | source
            end

            if test "$TERM" != "dumb"
              setup_visual_tools
            end

            fish_vi_key_bindings

            bind -M insert \ch kill-word
            bind -M insert \el true
            bind -M insert \ej true
            bind -M insert \ek true
            bind -M insert \eh true

            set -g fish_cursor_default block
            set -g fish_cursor_insert line
            set -g fish_cursor_replace_one underscore
            set -g fish_cursor_visual block

            function fish_user_key_bindings
              bind -M insert -m default jk backward-char force-repaint
            end

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
    };
}
