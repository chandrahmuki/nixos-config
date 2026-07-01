{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    gtk = {
      enable = true;
      iconTheme = {
        name = lib.mkDefault "Colloid-Teal-Catppuccin-Dark";
        package = lib.mkDefault (pkgs.colloid-icon-theme.override {
          schemeVariants = ["catppuccin"];
          colorVariants = ["teal"];
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

    stylix.targets.gtk.extraCss = ''
      @define-color headerbar_bg_color @window_bg_color;
      @define-color headerbar_backdrop_color @window_bg_color;
      @define-color sidebar_bg_color @window_bg_color;
      @define-color sidebar_backdrop_color @window_bg_color;

      headerbar, .sidebar, .navigation-sidebar, .placessidebar {
          border: none;
          box-shadow: none;
      }

      /* Masquer la barre latérale de Nautilus */
      .nautilus-window .navigation-sidebar,
      .nautilus-window placessidebar {
          width: 0px !important;
          min-width: 0px !important;
          max-width: 0px !important;
          opacity: 0 !important;
          visibility: hidden !important;
          margin: 0 !important;
          padding: 0 !important;
          border: none !important;
      }
    '';

    home.packages = with pkgs; [
      hicolor-icon-theme # Base icon theme (fallback)
    ];

    # Symlinks pour les icônes manquantes dans les thèmes standards
    home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source = "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

    # Force libadwaita to use dark theme
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkDefault "prefer-dark";
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
