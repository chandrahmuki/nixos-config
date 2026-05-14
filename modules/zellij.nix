{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    let
      zellij-status = pkgs.fetchurl {
        url = "https://github.com/scottames/zellij-status/releases/download/v0.4.0/zellij-status.wasm";
        sha256 = "0l53qbjhb0qfb72sil1vwgwiswsmi3hdsavd6bwd4203rf2aarq4";
      };
      zellij-autolock = pkgs.fetchurl {
        url = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
        sha256 = "194fgd421w2j77jbpnq994y2ma03qzdlz932cxfhfznrpw3mdjb9";
      };
    in
    {
      home.file.".config/zellij/plugins/zellij-status.wasm".source = zellij-status;
      home.file.".config/zellij/plugins/zellij-autolock.wasm".source = zellij-autolock;

      home.file.".config/zellij/layouts/dev.kdl".text = ''
        layout {
            default_tab_template {
                pane size=1 borderless=true {
                    plugin location="zellij:tab-bar" {
                        position "bottom"
                        show_tabs true
                        show_mode true
                        show_session true
                    }
                }
                children
            }
            tab name="Dev" focus=true cwd="/home/${username}/nixos-config" {
                pane split_direction="vertical" {
                    pane name="neovim" command="nvim" size="56%"
                    pane size="43%" {
                        pane name="opencode" command="opencode" size="73%"
                        pane name="terminal" size="26%"
                    }
                }
                pane size=12 name="shell"
            }
            tab name="Monitoring" {
                pane command="btop"
            }
        }
      '';

      home.file.".config/zellij/layouts/dev-flex.kdl".text = ''
        layout {
            default_tab_template {
                pane size=1 borderless=true {
                    plugin location="zellij:tab-bar" {
                        position "bottom"
                        show_tabs true
                        show_mode true
                        show_session true
                    }
                }
                children
            }
            tab name="Dev" focus=true {
                pane split_direction="vertical" {
                    pane name="neovim" command="nvim" size="56%"
                    pane size="43%" {
                        pane name="opencode" command="opencode" size="73%"
                        pane name="terminal" size="26%"
                    }
                }
                pane size=12 name="shell"
            }
        }
      '';

      programs.fish.shellAliases = {
        zellnix = "zellij --layout dev";
        zelldev = "zellij --layout dev-flex";
      };

      programs.fish.functions.zj = ''
        zellij attach main 2>/dev/null; or zellij --session main
      '';

      programs.zellij = {
        enable = true;
        enableFishIntegration = false;

        extraConfig = ''
          themes {
              tokyonight-moon {
                  bg 30 30 46
                  fg 197 202 221
                  black 69 71 90
                  red 243 139 168
                  green 166 227 161
                  blue 137 180 250
                  yellow 249 226 175
                  magenta 203 166 247
                  cyan 148 226 213
                  white 197 202 221
                  orange 255 158 100
                  text_unselected {
                      base 108 112 134
                      background 24 24 38
                      emphasis_0 108 112 134
                      emphasis_1 108 112 134
                      emphasis_2 108 112 134
                      emphasis_3 108 112 134
                  }
                  text_selected {
                      base 137 180 250
                      background 49 50 68
                      emphasis_0 137 180 250
                      emphasis_1 137 180 250
                      emphasis_2 137 180 250
                      emphasis_3 137 180 250
                  }
                  ribbon_unselected {
                      base 108 112 134
                      background 30 30 46
                      emphasis_0 108 112 134
                      emphasis_1 108 112 134
                      emphasis_2 108 112 134
                      emphasis_3 108 112 134
                  }
                  ribbon_selected {
                      base 137 180 250
                      background 49 50 68
                      emphasis_0 137 180 250
                      emphasis_1 137 180 250
                      emphasis_2 137 180 250
                      emphasis_3 137 180 250
                  }
                  frame_unselected {
                      base 69 71 90
                      background 24 24 38
                      emphasis_0 69 71 90
                      emphasis_1 69 71 90
                      emphasis_2 69 71 90
                      emphasis_3 69 71 90
                  }
                  frame_selected {
                      base 137 180 250
                      background 24 24 38
                      emphasis_0 137 180 250
                      emphasis_1 137 180 250
                      emphasis_2 137 180 250
                      emphasis_3 137 180 250
                  }
              }
          }
          keybinds {
              normal {
                  bind "Alt Enter" { ToggleFocusFullscreen; }
              }
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
          layout_dir = "/home/${username}/.config/zellij/layouts";

          plugins = {
            autolock = {
              path = "file:/home/${username}/.config/zellij/plugins/zellij-autolock.wasm";
              is_enabled = true;
            };
          };
        };

      };
    };
}
