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
        # Only redone when the papirus-icon-theme store path (or this recipe,
        # the ":v2") changes, not on every switch.
        papirusMarker="$HOME/.local/share/icons/Papirus-Dark.src"
        papirusSrc="${pkgs.papirus-icon-theme}/share/icons"
        papirusDst="$HOME/.local/share/icons/Papirus-Dark"
        if [ ! -e "$papirusDst" ] || [ "$(cat "$papirusMarker" 2>/dev/null)" != "${pkgs.papirus-icon-theme}:v2" ]; then
          $DRY_RUN_CMD rm -rf $VERBOSE_ARG "$papirusDst"
          # cp -a keeps the theme's own symlinks. The old `cp -rL` followed
          # the size directories that link into the shared Papirus theme and
          # copied ~300k files (1.6 GB) on every Papirus update.
          $DRY_RUN_CMD cp -a "$papirusSrc/Papirus-Dark" "$papirusDst"
          $DRY_RUN_CMD chmod -R u+w "$papirusDst"
          # papirus-folders only edits real files (it skips symlinks) and
          # refuses a non-writable folder.svg, so places/ of the sizes it
          # recolours must be real copies; the rest of each size stays links.
          for size in 22x22 24x24 32x32 48x48 64x64; do
            if [ -L "$papirusDst/$size" ]; then
              $DRY_RUN_CMD rm "$papirusDst/$size"
              $DRY_RUN_CMD mkdir "$papirusDst/$size"
              for e in "$papirusSrc/Papirus-Dark/$size"/*; do
                $DRY_RUN_CMD ln -s "$e" "$papirusDst/$size/$(basename "$e")"
              done
            fi
            $DRY_RUN_CMD rm -rf "$papirusDst/$size/places"
            $DRY_RUN_CMD cp -rL "$papirusSrc/Papirus-Dark/$size/places" "$papirusDst/$size/places"
            $DRY_RUN_CMD chmod -R u+w "$papirusDst/$size/places"
          done
          # Relative links that left the theme dangle in the copy (GTK
          # hard-aborts on them, hit via Thunar's toolbar): make them
          # absolute store paths.
          if [ -z "$DRY_RUN_CMD" ]; then
            find "$papirusDst" -xtype l -print0 | while IFS= read -r -d "" l; do
              rel="''${l#"$papirusDst"/}"
              ln -sfn "$(realpath -m "$(dirname "$papirusSrc/Papirus-Dark/$rel")/$(readlink "$l")")" "$l"
            done
          fi
          $DRY_RUN_CMD printf '%s' "${pkgs.papirus-icon-theme}:v2" > "$papirusMarker"
          # A fresh copy is back to the default folder colour; put back the
          # last one muggy-theme chose.
          # papirus-folders needs awk, which the activation PATH lacks.
          PATH="${pkgs.gawk}/bin:$PATH" $DRY_RUN_CMD ${pkgs.papirus-folders}/bin/papirus-folders -R -t Papirus-Dark >/dev/null \
            || echo "papirus-folders -R failed: folder colour not restored" >&2
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
