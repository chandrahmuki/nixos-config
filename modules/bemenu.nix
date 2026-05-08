{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  colors = (import ../lib/colors.nix).tokyonight;
in

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      programs.bemenu = {
        enable = true;
        settings = {
          tb = "${colors.bg}";
          nb = "${colors.bg}";
          fb = "${colors.bg}";
          hb = "${colors.accent}";
          fb2 = "${colors.bg}";
          nb2 = "${colors.bg}";
          tb2 = "${colors.bg}";

          tf = "${colors.fg}";
          nf = "${colors.fg}";
          ff = "${colors.fg}";
          hf = "${colors.fg}";
          af = "${colors.fg}";

          ab = "${colors.accent}";

          border = "${colors.blue}";
          border-width = 2;

          line-height = 32;
          lines = 10;
          prompt = "";
          font = "JetBrainsMono Nerd Font 12";
          width = 30;
          ignorecase = true;
        };
      };

      home.sessionVariables = {
        BEMENU_BACKEND = "wayland";
      };
    };
}
