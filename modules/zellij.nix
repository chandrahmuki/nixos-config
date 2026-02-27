{ pkgs, ... }:

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
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.fish.shellAliases = {
    zelldev = "zellij --layout dev";
  };

  programs.zellij = {

    extraConfig = ''
      keybinds {
          shared_except "locked" {
              bind "Alt h" { MoveFocusOrTab "Left"; }
              bind "Alt l" { MoveFocusOrTab "Right"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
          }
      }
    '';

    settings = {
      pane_frames = false;
      theme = "tokyonight-moon";
      mouse_mode = true;
      copy_on_select = true;

      plugins = {
        autolock = {
          path = "file:${zellij-autolock}";
          is_enabled = true;
        };
      };
    };

    layouts = {
      dev = ''
        layout {
            default_tab_template {
                children
                pane size=1 borderless=true {
                    plugin location="file:${zjstatus}" {
                        format_left  "{mode}#[fg=#89b4fa,bold] {session} {tabs}"
                        format_right "{command_git_branch}#[fg=#424242,bold] | {datetime}"
                        format_space ""

                        border_enabled  "false"
                        border_char     "─"
                        border_format   "#[fg=#6C7086]{char}"
                        border_position "top"

                        hide_frame_for_single_pane "true"

                        mode_normal  "#[bg=#89b4fa,fg=#181825,bold] NORMAL "
                        mode_locked  "#[bg=#f38ba8,fg=#181825,bold] LOCKED "
                        mode_tmux    "#[bg=#ff9e64,fg=#181825,bold] TMUX "

                        tab_normal   "#[fg=#6C7086] {name} "
                        tab_active   "#[fg=#89b4fa,bold,italic] {name} "

                        command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                        command_git_branch_format      "#[fg=blue] {stdout} "
                        command_git_branch_interval    "10"
                        command_git_branch_rendermode  "static"

                        datetime        "#[fg=#6C7086,bold] {format} "
                        datetime_format "%H:%M"
                        datetime_timezone "Europe/Paris"
                    }
                }
            }
            tab name="Editor" focus=true {
                pane split_direction="vertical" {
                    pane command="nvim" name="MuggyVim" focus=true {
                        args "."
                    }
                    pane size="25%" {
                        pane name="Gemini CLI" command="gemini"
                        pane name="Terminal"
                    }
                }
            }
            tab name="Server/Logs" {
                pane
            }
        }
      '';
    };
  };
}
