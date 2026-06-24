{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  stylix = {
    enable = true;
    image = /. + "/home/${username}/Pictures/wallpaper/wallpaperGnome.png";
    base16Scheme = {
      base00 = "2b3a36";
      base01 = "354742";
      base02 = "5e3a4d";
      base03 = "6d877f";
      base04 = "b3a79f";
      base05 = "dfd5cd";
      base06 = "eae2db";
      base07 = "f5f0ec";
      base08 = "ffc2d4";
      base09 = "ffb37e";
      base0A = "e9d8a6";
      base0B = "00f5d4";
      base0C = "8efdf0";
      base0D = "90e0ef";
      base0E = "a8708d";
      base0F = "d4a373";
    };
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 11;
        terminal = 11;
        desktop = 10;
        popups = 10;
      };
    };

    targets.gnome.enable = true;
    targets.qt.platform = lib.mkForce "qtct";
  };

  home-manager.users.${username} = {
    stylix.targets.zen-browser.profileNames = [ "default" ];
  };
}
