{ pkgs, ... }:
{
  imports = [
    ./binds.nix
    ./style.nix
  ];

  programs.niri.settings = {

    # deactivate niri hotkey pannel at startup
    hotkey-overlay.skip-at-startup = true;

    input.keyboard.xkb = {
      layout = "us";
      model = "pc104";
      variant = "intl";
    };

    prefer-no-csd = true;

    spawn-at-startup = [
      # { command = [ "sleep 15; systemctl --user restart swaybg" ]; }
      { command = [ "xwayland-satellite" ]; }
    ];

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

    # Configuration des écrans
    # DP-2 (2K) à gauche, HDMI-A-1 (4K) à droite
    outputs = {
      "DP-2" = {
        # Écran 2K AOC (à gauche, avec 75Hz)
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
        # Écran 4K LG (à droite)
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.0;
        };
        scale = 2.0; # Scale 2x pour 4K
        position = {
          x = 2560; # Juste après le 2K
          y = 0;
        };
      };
    };

  };
}
