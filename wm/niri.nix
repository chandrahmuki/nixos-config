{ pkgs, ... }:
{
  imports = [
    ./binds.nix
    ./style.nix
  ];

  programs.niri.settings = {

    input.keyboard.xkb = {
      layout = "us";
      model = "pc104";
      variant = "intl";
      options = "grp:alt_space_toggle";
    };

    prefer-no-csd = true;

    spawn-at-startup = [
      { command = [ "sleep 15; systemctl --user restart swaybg" ]; }
      { command = [ "xwayland-satellite" ]; }
      { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }

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

  };
}
