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
                        plugin location="zellij:tab-bar"
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
