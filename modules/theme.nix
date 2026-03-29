{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    # GTK Theme Configuration
        gtk = {
          enable = true;
          theme = {
            name = "Tokyonight-Moon-BL-LB";
            package = pkgs.tokyonight-gtk-theme;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
          cursorTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
          };
          gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
          gtk4.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };

        home.packages = with pkgs; [
          hicolor-icon-theme # Base icon theme (fallback)
        ];

        # Symlinks pour les icônes manquantes dans les thèmes standards
        home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source =
          "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

        # Pour Antigravity, on essaie de pointer vers son icône si elle est packagée
        home.file.".local/share/icons/hicolor/scalable/apps/antigravity.svg".source = "${
          pkgs.antigravity-unwrapped or pkgs.antigravity
        }/share/icons/hicolor/scalable/apps/antigravity.svg";

        # Force libadwaita to use dark theme
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };

        # Cursor size and theme for X11/Wayland
        home.pointerCursor = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
          size = 24;
          gtk.enable = true;
          x11.enable = true;
        };
  };
}
