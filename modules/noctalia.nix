{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true; # Auto-start avec Niri/Wayland

    # Configuration Noctalia (basée sur la doc)
    settings = {
      bar = {
        position = "top";
        floating = true;
        backgroundOpacity = 0.7; # Plus de transparence
        margin = 10;
        radius = 12;
        output = "HDMI-A-1"; # Afficher uniquement sur l'écran 2K
      };

      general = {
        animationSpeed = 1.0;
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
