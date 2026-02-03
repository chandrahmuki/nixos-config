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
      { command = [ "sleep 15; systemctl --user restart swaybg" ]; }
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
    # 2K à gauche, 4K à droite
    outputs = {
      "HDMI-A-1" = {
        # Écran 2K à gauche (pas de scale)
        mode = {
          width = 2560;
          height = 1440;
          refresh = 59.951;
        };
        scale = 1.0; # Pas de scale sur le 2K
        position = {
          x = 0;
          y = 0;
        };
      };
      "DP-2" = {
        # Écran 4K à droite
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.0;
        };
        scale = 2.0; # Scale 2x pour 4K (1920x1080 logique)
        position = {
          x = 2560; # Juste après le 2K (2560 pixels logiques)
          y = 0;
        };
      };
    };

  };
}
