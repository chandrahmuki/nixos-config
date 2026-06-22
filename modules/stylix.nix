{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  stylix = {
    enable = true;
    image = pkgs.nixos-artwork.wallpapers.simple-dark-gray.src;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
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
  };

  home-manager.users.${username} = {
    stylix.targets.yazi.enable = false;
    stylix.targets.foot.enable = false;
    stylix.targets.btop.enable = false;
    stylix.targets.fuzzel.enable = false;
    stylix.targets.zathura.enable = false;
    stylix.targets.vscode.enable = false;
  };
}
