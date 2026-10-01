{den, ...}: {
  den.aspects.terminal.nixos = {
    config,
    lib,
    pkgs,
    username,
    hostname,
    ...
  }: {
    # Stylix ships a SEPARATE fish target at the NixOS level (it themes the
    # system-wide /etc/fish/config.fish, sourced by every interactive shell
    # in addition to the per-user one below). Disabling the Home Manager
    # target alone still leaves this one pushing the static base16 palette
    # over OSC escapes on every shell start, undoing Matugen/kitty live.
    stylix.targets.fish.enable = false;

    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      # Kitty is owned by the runtime Matugen palette, not the static Stylix
      # fallback. Its remote-control socket updates open windows immediately.
      stylix.targets.kitty.enable = false;
      # Starship uses ANSI names (cyan, blue, purple, etc.) so Kitty's live
      # Matugen palette recolors each new prompt. A fixed Stylix palette would
      # keep the prompt on the old theme after Muggy switches themes.
      stylix.targets.starship.enable = false;
      # Same reasoning, for the per-user (Home Manager) fish target.
      stylix.targets.fish.enable = false;

      programs = {
        kitty = {
          enable = true;
          settings = {
            font_family = "Cozette";
            font_size = 18;
            # Match Foot's readable translucent/blurred desktop treatment.
            background_opacity = 0.78;
            dynamic_background_opacity = true;
            allow_remote_control = "yes";
            # Kitty silently suffixes a bare listen_on path with its own PID
            # anyway; spell it out so muggy-theme can glob every live window's
            # socket instead of guessing a path that never actually exists.
            listen_on = "unix:/run/user/1000/kitty-{kitty_pid}";
          };
          extraConfig = ''
            include /home/${username}/.cache/muggy/kitty-theme.conf
          '';
          shellIntegration.enableFishIntegration = true;
        };

        # Keep Foot available as the lightweight fallback.
        foot = {
          enable = true;
          settings = {
            main = {
              font = lib.mkForce "Cozette:size=18";
              pad = "15x15";
            };
            "colors-dark" = {
              alpha = lib.mkForce "0.78";
              blur = true;
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
            format = "[╭─](bold cyan)$os$directory$git_branch$git_status$nix_shell$cmd_duration$status\n$character";
            os = {
              disabled = false;
              format = "[$symbol]($style) ";
              style = "bold cyan";
              symbols.NixOS = "";
            };
            directory = {
              style = "bold blue";
              truncation_length = 3;
              truncation_symbol = "…/";
              format = "[$path]($style)[$read_only]($read_only_style) ";
            };
            git_branch = {
              symbol = " ";
              style = "bold purple";
              format = "[$symbol$branch]($style) ";
            };
            git_status = {
              style = "bold yellow";
              format = "([$all_status$ahead_behind]($style) )";
            };
            character = {
              success_symbol = "[╰─❯](bold cyan)";
              error_symbol = "[╰─❯](bold red)";
            };
            nix_shell = {
              symbol = "❄ ";
              style = "bold cyan";
              format = "[$symbol$name]($style) ";
            };
            cmd_duration = {
              min_time = 2000;
              style = "bold yellow";
              format = "[⌛ $duration]($style) ";
            };
            status = {
              disabled = false;
              style = "bold red";
              symbol = "✘ ";
              format = "[$symbol$status]($style) ";
              map_symbol = false;
              recognize_signal_code = true;
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
            fish_add_path --prepend /run/wrappers/bin
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

              # The test builtin offers operators like "!=" after `test ",
              # which look like stray glyphs in this prompt. Keep other
              # commands' completions and fish autosuggestions unchanged.
              complete -c test -e
              complete -c test -f

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
  };
}
