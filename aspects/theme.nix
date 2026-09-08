{den, ...}: {
  den.aspects.theme.nixos = {
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
    }: let
      monochromeIcons = pkgs.stdenvNoCC.mkDerivation {
        pname = "catppuccin-mono-light-icons";
        version = "1.0";
        src = pkgs.fetchzip {
          url = "https://github.com/nirabyte/full-icon-themes/releases/download/v1.0/catppuccin.tar.xz";
          hash = "sha256-3HUnHW/kJL7/4z9+Dy4M0J3XFBCy3qJ8AU9TRcowsvw=";
          stripRoot = false;
        };
        dontUnpack = true;
        installPhase = ''
          mkdir -p "$out/share/icons"
          cp -r "$src/catppuccin-mono-light" "$out/share/icons/"
        '';
      };
    in {
      gtk = {
        enable = true;
        iconTheme = {
          name = lib.mkDefault "catppuccin-mono-light";
          package = lib.mkDefault monochromeIcons;
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

      '';

      home.packages = with pkgs; [
        hicolor-icon-theme # Base icon theme (fallback)
      ];

      # Symlinks pour les icônes manquantes dans les thèmes standards
      home.file.".local/share/icons/catppuccin-mono-light".source = "${monochromeIcons}/share/icons/catppuccin-mono-light";
      home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source = "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

      # Force libadwaita to use dark theme
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = lib.mkDefault "prefer-dark";
        };
      };

      # Cursor size and theme for X11/Wayland
      home.pointerCursor = {
        enable = true;
        name = lib.mkDefault "Adwaita";
        package = lib.mkDefault pkgs.adwaita-icon-theme;
        size = lib.mkDefault 24;
        gtk.enable = lib.mkDefault true;
        x11.enable = lib.mkDefault true;
      };
    };
  };
}
