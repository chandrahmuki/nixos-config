{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  environment.sessionVariables = {
    GTK_THEME = "catppuccin-mocha-lavender-standard:dark";
  };

  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    gtk = {
      enable = true;
      theme = {
        name = lib.mkDefault "catppuccin-mocha-lavender-standard";
        package = lib.mkDefault (pkgs.catppuccin-gtk.override {
          accents = [ "lavender" ];
          size = "standard";
          variant = "mocha";
        });
      };
      iconTheme = {
        name = lib.mkDefault "Colloid-Catppuccin-Dark";
        package = lib.mkDefault (pkgs.colloid-icon-theme.override {
          schemeVariants = [ "catppuccin" ];
        });
      };
      cursorTheme = {
        name = lib.mkDefault "Adwaita";
        package = lib.mkDefault pkgs.adwaita-icon-theme;
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
    home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source = "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

    # Force libadwaita to use dark theme and configure shell theme
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkDefault "prefer-dark";
      };
      "org/gnome/shell/extensions/user-theme" = {
        name = lib.mkDefault "catppuccin-mocha-lavender-standard";
      };
    };

    # Cursor size and theme for X11/Wayland
    home.pointerCursor = {
      name = lib.mkDefault "Adwaita";
      package = lib.mkDefault pkgs.adwaita-icon-theme;
      size = lib.mkDefault 24;
      gtk.enable = lib.mkDefault true;
      x11.enable = lib.mkDefault true;
    };
  };
}
