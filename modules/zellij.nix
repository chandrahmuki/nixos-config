{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }:
    let
      zjstatus = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
        sha256 = "0lyxah0pzgw57wbrvfz2y0bjrna9bgmsw9z9f898dgqw1g92dr2d";
      };
      zellij-autolock = pkgs.fetchurl {
        url = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
        sha256 = "194fgd421w2j77jbpnq994y2ma03qzdlz932cxfhfznrpw3mdjb9";
      };
    in
    {
      home.file.".config/zellij/plugins/zjstatus.wasm".source = zjstatus;
      home.file.".config/zellij/plugins/zellij-autolock.wasm".source = zellij-autolock;

      programs.fish.shellAliases = {
        zelldev = "cd /home/${username}/nixos-config && zellij --layout dev attach -c dev";
      };

      programs.zellij = {
        enable = true;
        enableFishIntegration = false;

        extraConfig = ''
          keybinds {
              shared_except "locked" {
                  bind "Alt h" { MoveFocusOrTab "Left"; }
                  bind "Alt l" { MoveFocusOrTab "Right"; }
                  bind "Alt j" { MoveFocus "Down"; }
                  bind "Alt k" { MoveFocus "Up"; }
                  bind "Alt n" { NewTab; }
                  bind "Alt w" { CloseTab; }
              }
          }
        '';

        settings = {
          default_shell = "/run/current-system/sw/bin/fish";
          default_layout = "dev";
          pane_frames = false;
          theme = "tokyonight-moon";
          mouse_mode = true;
          copy_on_select = true;
          session_serialization = false;
          pane_viewport_serialization = false;
          
          plugins = {
            autolock = {
              path = "file:/home/${username}/.config/zellij/plugins/zellij-autolock.wasm";
              is_enabled = true;
            };
          };
        };

        layouts = {
          dev = ''
            layout {
                default_tab_template {
                    pane size=1 borderless=true {
                        plugin location="https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm" {
                            format_left  "#[fg=#82a1ff,bold] 󰣆  {mode} #[fg=#3b4261,bold] {tabs}"
                            format_right "#[fg=#82a1ff,bold]󰉖 {session} #[fg=#3b4261]| #[fg=#7aa2f7]󰊢 {command_git_branch} #[fg=#3b4261]| #[fg=#82a1ff]{datetime}"
                            format_space "#[bg=#1e2030]"

                            border_enabled  "false"
                            hide_frame_for_single_pane "true"

                            mode_normal  "#[fg=#82a1ff,bold]NORMAL"
                            mode_locked  "#[fg=#f7768e,bold]LOCKED"
                            mode_tmux    "#[fg=#ff9e64,bold]TMUX"

                            tab_normal              "#[fg=#565f89] {name} "
                            tab_active              "#[fg=#82a1ff,bold,italic] {name} "
                            tab_separator           "#[fg=#3b4261,bold]|"

                            command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                            command_git_branch_format      "#[fg=#7aa2f7] {stdout} "
                            command_git_branch_interval    "10"
                            command_git_branch_rendermode  "static"

                            datetime        "#[fg=#82a1ff,bold] {format} "
                            datetime_format "%H:%M"
                            datetime_timezone "Europe/Paris"
                        }
                    }
                    children
                }

                tab name="Dev" focus=true split_direction="horizontal" {
                    pane split_direction="vertical" size="80%" {
                        pane command="nvim" name="MuggyVim" focus=true size="75%" {
                            args "."
                            cwd "/home/${username}/nixos-config"
                        }
                        pane command="gemini" name="AI Workspace" size="25%" {
                            cwd "/home/${username}/nixos-config"
                        }
                    }
                    pane name="Terminal" size="20%" {
                        cwd "/home/${username}/nixos-config"
                    }
                }
            }
          '';
        };
      };
    };
}
