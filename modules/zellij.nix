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

      home.file.".config/zellij/layouts/dev.kdl".text = ''
        layout {
            default_tab_template {
                children
                pane size=1 {
                    plugin location="zellij:compact-bar"
                }
            }
            tab name="Editor" focus=true
            tab name="Server/Logs"
        }
      '';

      programs.fish.shellAliases = {
        zelldev = "zellij --layout dev";
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
              }
          }
          ui {
              pane_frames {
                  rounded_corners true
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
