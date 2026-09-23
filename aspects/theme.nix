{den, ...}: {
  den.aspects.theme.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
}: let
  catppuccinMonoIcons = pkgs.stdenvNoCC.mkDerivation {
    pname = "catppuccin-mono-light-icons";
    version = "1.0";
    src = pkgs.fetchurl {
      url = "https://github.com/nirabyte/full-icon-themes/releases/download/v1.0/catppuccin.tar.xz";
      hash = "sha256-2U8PjJGBoJzyTNceyeYOKnE4SVmqE4AYkskONql/xlk=";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/icons
      tar -xJf $src -C $out/share/icons
    '';
  };
in {
    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      gtk = {
        enable = true;
        iconTheme = {
          name = lib.mkDefault "Papirus-Dark";
          package = lib.mkDefault pkgs.papirus-icon-theme;
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
        /* Written at runtime by muggy-theme after Matugen runs. */
        @import url("file:///home/${username}/.cache/muggy/gtk-matugen.css");

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
        papirus-icon-theme
        catppuccinMonoIcons
        # `papirus-folders -C <color> -t Papirus-Dark` recolors just the
        # folder icons; muggy-theme calls it on every apply. It refuses to
        # touch a theme it can't write to, so the Nix-store copy above is
        # useless to it — the activation script below gives it a writable
        # one under ~/.local/share/icons instead (XDG data dirs put that
        # ahead of the store copy for everything else, so nothing else
        # regresses).
        papirus-folders
      ];

      # Keep the monochrome app pack available specifically for the Quickshell
      # launcher without replacing Papirus-Dark as the global GTK icon theme.
      home.file.".local/share/icons/catppuccin-mono-light".source =
        "${catppuccinMonoIcons}/share/icons/catppuccin-mono-light";

      # Symlink pour l'icône manquante dans le thème standard
      home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source = "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

      home.activation.mutablePapirusDark = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # The copy below (-L dereferencing ~7600 files) takes several
        # seconds; skip it when this generation's papirus-icon-theme store
        # path hasn't changed since the last activation instead of paying
        # that cost on every single switch.
        papirusMarker="$HOME/.local/share/icons/Papirus-Dark.src"
        if [ ! -e "$HOME/.local/share/icons/Papirus-Dark" ] || [ "$(cat "$papirusMarker" 2>/dev/null)" != "${pkgs.papirus-icon-theme}" ]; then
          $DRY_RUN_CMD rm -rf $VERBOSE_ARG "$HOME/.local/share/icons/Papirus-Dark"
          # -L: dereference symlinks into real files. Papirus-Dark's own
          # tree links out to shared assets (e.g. status/image-missing.svg)
          # elsewhere in the package; copied as bare symlinks they dangle
          # outside their original parent and GTK hard-aborts the whole app
          # the first time it tries to load one (hit via Thunar's toolbar).
          $DRY_RUN_CMD cp -rL ${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark "$HOME/.local/share/icons/Papirus-Dark"
          $DRY_RUN_CMD chmod -R u+w "$HOME/.local/share/icons/Papirus-Dark"
          $DRY_RUN_CMD printf '%s' "${pkgs.papirus-icon-theme}" > "$papirusMarker"
        fi
      '';

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
