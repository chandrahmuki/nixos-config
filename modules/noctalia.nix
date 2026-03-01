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
  };

  # Définition de la variable d'environnement pour que Noctalia lise et écrive
  # ses paramètres (dont la position des widgets) directement dans le dossier Git.
  home.sessionVariables = {
    NOCTALIA_SETTINGS_FILE = "${config.home.homeDirectory}/nixos-config/generated/noctalia-settings.json";
  };
}
