{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Configuration du fond d'écran pour Noctalia
  home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
    defaultWallpaper = "/home/david/Pictures/wallpaper/wallpaper.png";
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
            { id = "MediaMini"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "Tray"; }
            { id = "NotificationHistory"; }
            { id = "Battery"; }
            { id = "Volume"; }
            { id = "Brightness"; }
            { id = "ControlCenter"; }
          ];
        };
      };

      general = {
        animationSpeed = 1.5; # Plus rapide (x1.5)
        radiusRatio = 1.0;
      };

      colorSchemes = {
        darkMode = true;
        useWallpaperColors = true; # Support matugen/dynamic theming
      };
    };

    # On peut aussi définir des plugins ici si besoin
    # plugins = { ... };
  };
}
