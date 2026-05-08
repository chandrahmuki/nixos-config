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
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "JetBrainsMono Nerd Font:size=12";
            dpi-aware = "no";
            lines = 10;
            width = 40;
            horizontal-pad = 20;
            vertical-pad = 16;
            inner-pad = 8;
          };
          colors = {
            background = "${colors.bg}ff";
            text = "${colors.fg}ff";
            prompt = "${colors.fg}ff";
            placeholder = "${colors.comment}ff";
            input = "${colors.fg}ff";
            match = "${colors.blue}ff";
            selection = "${colors.accent}ff";
            selection-text = "${colors.fg}ff";
            selection-match = "${colors.blue}ff";
            border = "${colors.blue}ff";
          };
          border = {
            width = 2;
            radius = 12;
          };
        };
      };
    };
}
