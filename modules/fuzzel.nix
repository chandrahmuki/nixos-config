{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  colors = (import ../lib/colors.nix).tokyonight-storm;
in {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = lib.mkForce "JetBrainsMono Nerd Font:size=11";
          dpi-aware = "no";
          lines = 8;
          width = 35;
          horizontal-pad = 12;
          vertical-pad = 10;
          inner-pad = 6;
          line-height = 22;
          tabs = 4;
          layer = "overlay";
          anchor = "center";
          icons-enabled = false;
        };
        border = {
          width = 2;
          radius = 16;
        };
        cursor = {
          style = "beam";
        };
      };
    };
  };
}
