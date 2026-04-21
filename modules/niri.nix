{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:

{
  # 1. Importation du module NixOS du flake
  imports = [
    inputs.niri.nixosModules.niri
  ];

  # 2. Configuration au niveau Système (NixOS)
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable; # On garde ton package habituel
  };

  # 3. Configuration au niveau Utilisateur (Dendritic)
  # Le module NixOS de sodiboo expose les réglages HM via cette structure
  home-manager.users.${username} =
    { config, lib, ... }:
    {

      programs.niri.settings = {
        # --- CONFIGURATION DE BASE ---
        hotkey-overlay.skip-at-startup = true;

        input.keyboard.xkb = {
          layout = "us";
          model = "pc104";
          variant = "intl";
        };

        prefer-no-csd = true;

        spawn-at-startup = [
          { command = [ "xwayland-satellite" ]; }
          { command = [ "noctalia-shell" ]; }
        ];

        debug = {
          honor-xdg-activation-with-invalid-serial = true;
          deactivate-unfocused-windows = true;
        };

        environment."DISPLAY" = ":0";

        layout.default-column-width = {
          proportion = 1. / 2.;
        };

        layout.preset-column-widths = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
        ];

        layout.preset-window-heights = [
          { proportion = 1.; }
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
        ];

        outputs = {
          "DP-2" = {
            mode = {
              width = 2560;
              height = 1440;
              refresh = 74.968;
            };
            scale = 1.0;
            position = {
              x = 0;
              y = 0;
            };
          };
          "HDMI-A-1" = {
            mode = {
              width = 3840;
              height = 2160;
              refresh = 60.0;
            };
            scale = 2.0;
            position = {
              x = 2560;
              y = 0;
            };
          };
        };

        # --- STYLE ET APPARENCE ---
        layout = {
          gaps = 16;
          focus-ring.width = 6;
          focus-ring.active.color = "rgba(255,255,255,0.3)";
          focus-ring.inactive.color = "rgba(100,100,100,0.3)";
        };

        window-rules = [
          {
            matches = [ { app-id = "^steam.*$"; } ];
            open-on-output = "DP-2";
            open-fullscreen = true;
          }
          {
            matches = [ { app-id = "brave-browser"; } ];
            open-focused = true;
          }
          {
            geometry-corner-radius = {
              bottom-left = 12.0;
              bottom-right = 12.0;
              top-left = 12.0;
              top-right = 12.0;
            };
            clip-to-geometry = true;
          }
        ];

        # --- RACCOURCIS CLAVIER ---
        binds = with config.lib.niri.actions; {
          "Mod+D".action = spawn "walker";
          "Mod+M".action = spawn [ "music-menu" ];
          "Mod+Y".action = spawn [ "yt-search" ];
          "Mod+Shift+Y".action = spawn [
            "yt-search"
            "--audio"
          ];
          "Mod+Q".action = close-window;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+F".action = maximize-column;
          "Mod+T".action = spawn "foot";
          "Mod+Shift+E".action = quit { skip-confirmation = false; };
          "Mod+Shift+Slash".action = show-hotkey-overlay;
          "Mod+Shift+Space".action = toggle-window-floating;
          "Mod+Space".action = switch-focus-between-floating-and-tiling;
          "Mod+O".action.toggle-overview = [ ];

          "Mod+W".action = switch-preset-column-width;
          "Mod+H".action = switch-preset-window-height;
          "Mod+C".action = consume-window-into-column;
          "Mod+X".action = expel-window-from-column;

          "Mod+Left".action = focus-column-or-monitor-left;
          "Mod+Right".action = focus-column-or-monitor-right;
          "Mod+Up".action = focus-window-or-workspace-up;
          "Mod+Down".action = focus-window-or-workspace-down;

          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;

          "XF86MonBrightnessUp".action = spawn "brightnessctl s +10%";
          "XF86MonBrightnessDown".action = spawn "brightnessctl s -10%";

          "Mod+Ctrl+equal".action = spawn [
            "${pkgs.pamixer}/bin/pamixer"
            "-i"
            "5"
          ];
          "Mod+Ctrl+minus".action = spawn [
            "${pkgs.pamixer}/bin/pamixer"
            "-d"
            "5"
          ];
          "Mod+Ctrl+0".action = spawn [
            "${pkgs.pamixer}/bin/pamixer"
            "-t"
          ];
          "Mod+Ctrl+p".action = spawn [
            "${pkgs.playerctl}/bin/playerctl"
            "play-pause"
          ];
          "Mod+Ctrl+bracketright".action = spawn [
            "${pkgs.playerctl}/bin/playerctl"
            "next"
          ];
          "Mod+Ctrl+bracketleft".action = spawn [
            "${pkgs.playerctl}/bin/playerctl"
            "previous"
          ];

          "Mod+Shift+Left".action = move-column-left-or-to-monitor-left;
          "Mod+Shift+Right".action = move-column-right-or-to-monitor-right;
          "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
          "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;

          "Mod+Shift+1".action = move-column-to-index 1;
          "Mod+Shift+2".action = move-column-to-index 2;
          "Mod+Shift+3".action = move-column-to-index 3;
          "Mod+Shift+4".action = move-column-to-index 4;
          "Mod+Shift+5".action = move-column-to-index 5;
          "Mod+Shift+6".action = move-column-to-index 6;
          "Mod+Shift+7".action = move-column-to-index 7;
          "Mod+Shift+8".action = move-column-to-index 8;
          "Mod+Shift+9".action = move-column-to-index 9;

          "Mod+WheelScrollDown".action = focus-column-right;
          "Mod+WheelScrollUp".action = focus-column-left;
          "Mod+Shift+WheelScrollDown".action = focus-workspace-down;
          "Mod+Shift+WheelScrollUp".action = focus-workspace-up;

          "Ctrl+Mod+S".action.screenshot = [ ];
          "Ctrl+Mod+Shift+S".action.screenshot-screen = [ ];
        };
      };
    };
}
