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
    # Pour que la souris aille de 2K (gauche) vers 4K (droite)
    outputs = {
      "HDMI-A-1" = {
        # Écran 2K (celui que tu veux à gauche)
        mode = {
          width = 2560;
          height = 1440;
          refresh = 59.951;
        };
        position = {
          x = 0;
          y = 0;
        };
      };
      "DP-2" = {
        # Écran 4K (à droite du 2K)
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.0;
        };
        scale = 1.5; # Scale pour 4K (optionnel, ajuste si besoin)
        position = {
          x = 2560; # À droite de l'écran 2K
          y = 0;
        };
      };
    };

  };
}
