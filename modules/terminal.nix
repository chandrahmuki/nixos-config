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
  }: {
    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      programs = {
        foot = {
          enable = true;
          settings = {
            main = {
              font = lib.mkForce "JetBrainsMono Nerd Font:size=18";
              pad = "15x15";
            };
            key-bindings = {
              font-increase = "Control+plus";
              font-decrease = "Control+minus";
            };
          };
        };

        eza = {
          enable = true;
          enableFishIntegration = true;
          icons = "auto";
          git = true;
          extraOptions = [
            "--group-directories-first"
            "--header"
          ];
        };

        starship = {
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

        zoxide = {
          enable = true;
          enableFishIntegration = true;
          options = ["--cmd cd"];
        };

        fish = {
          enable = true;
          interactiveShellInit = ''
            set -g fish_greeting ""

            function tx
                foot -f "JetBrainsMono Nerd Font:size=10" fish -c "tmux attach || tmux new-session" &
                disown
            end

            set -l _gh_token_file ~/.config/sops/github_token
            if test -f $_gh_token_file
              set -gx GITHUB_TOKEN (cat $_gh_token_file)
            end

            set -l _opencode_key ~/.config/sops/opencode_api_key
            if test -f $_opencode_key
              set -gx OPENCODE_API_KEY (cat $_opencode_key)
            end

            if status is-interactive
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
          };
        };
      };
    };
  }
