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

      programs.zellij = {
        enable = true;
        enableFishIntegration = false;
      };

      programs.fish.shellAliases = {
        zelldev = "cd /home/${username}/nixos-config && zellij --layout dev attach -c dev";
      };

      programs.zellij = {
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
                            format_left  "{mode} #[fg=#89b4fa,bold]{tabs}"
                            format_right "#[fg=#89b4fa,bold]󰉖 {session} #[fg=#424242]| #[fg=#89b4fa]󰊢 {command_git_branch} #[fg=#424242]| {datetime}"
                            format_space ""

                            border_enabled  "false"
                            border_char     "─"
                            border_format   "#[fg=#6C7086]{char}"
                            border_position "top"

                            hide_frame_for_single_pane "true"

                            mode_normal  "#[bg=#89b4fa,fg=#181825,bold] 󰣆 "
                            mode_locked  "#[bg=#f38ba8,fg=#181825,bold] 󰌾 "
                            mode_tmux    "#[bg=#ff9e64,fg=#181825,bold] 󰓩 "

                            tab_normal   "#[fg=#6C7086] {name} "
                            tab_active   "#[fg=#89b4fa,bold,italic] {name} "

                            command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                            command_git_branch_format      "#[fg=blue] {stdout} "
                            command_git_branch_interval    "10"
                            command_git_branch_rendermode  "static"

                            datetime        "#[fg=#89b4fa,bold] {format} "
                            datetime_format "%H:%M"
                            datetime_timezone "Europe/Paris"
                        }
                    }
                    children
                }

                tab name="Dev" focus=true {
                    pane split_direction="vertical" {
                        pane command="nvim" name="MuggyVim" focus=true {
                            args "."
                            size "70%"
                            cwd "/home/${username}/nixos-config"
                        }
                        pane name="Gemini CLI" {
                            command "gemini"
                            size "30%"
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