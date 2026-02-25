{ config, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Configuration du fond d'écran pour Noctalia
  home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
    defaultWallpaper = "${config.home.homeDirectory}/Pictures/wallpaper/wallpaper.png";
  };

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true; # Auto-start avec Niri/Wayland

    # Configuration Noctalia (basée sur la doc)
    settings = {
      bar = {
        position = "left"; # Barre sur le côté gauche
        barType = "floating"; # Style flottant
        floating = true;
        backgroundOpacity = 0.5; # Transparence 50%
        useSeparateOpacity = true;
        monitors = [ "DP-2" ]; # Afficher uniquement sur l'écran 2K (AOC)
        margin = 10;
        marginVertical = 10;
        marginHorizontal = 10;

        # Widgets sans le Launcher
        widgets = {
          left = [
            # { id = "Launcher"; }  # Retiré !
            { id = "Clock"; }
            { id = "SystemMonitor"; }
            { id = "ActiveWindow"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "Tray"; }
            # { id = "NotificationHistory"; } # Retiré à la demande de l'utilisateur
            { id = "Battery"; }
            { id = "Volume"; }
            { id = "Brightness"; }
            { id = "ControlCenter"; }
          ];
        };
      };

      desktopWidgets = {
        enabled = true;
        monitorWidgets = [
          {
            name = "HDMI-A-1";
            widgets = [
              {
                id = "Clock";
                x = 33;
                y = 45;
                scale = 0.5279141523625126;
                format = "HH:mm\nd MMMM yyyy";
                showBackground = true;
              }
              {
                id = "plugin:media-mixer";
                x = 134;
                y = 52;
                scale = 1;
              }
            ];
          }
        ];
      };

      general = {
        animationSpeed = 1.5; # Plus rapide (x1.5)
        radiusRatio = 1.0;
      };

      notifications = {
        enabled = false;
      };

      colorSchemes = {
        darkMode = true;
        schemeType = "vibrant";
        useWallpaperColors = false; # Desactive l'extraction auto pour forcer TokyoNight
        
        # Palette TokyoNight Moon (Material 3 Aliases)
        customPalette = {
          mPrimary = "#7aa2f7";       # Blue
          mOnPrimary = "#1a1b26";     # Background
          mSecondary = "#bb9af7";     # Magenta
          mOnSecondary = "#1a1b26";
          mTertiary = "#7dcfff";      # Cyan
          mOnTertiary = "#1a1b26";
          mSurface = "#1a1b26";       # Background
          mOnSurface = "#c0caf5";     # Foreground
          mSurfaceVariant = "#24283b";# Darker Background
          mOnSurfaceVariant = "#a9b1d6";
          mOutline = "#414868";       # Selection/Border
          mError = "#f7768e";         # Red
          mOnError = "#1a1b26";
        };
      };
    };

    # On peut aussi définir des plugins ici si besoin
    # plugins = { ... };
  };
}
