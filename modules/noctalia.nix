{ config, lib, pkgs, username, inputs, ... }:

{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  home-manager.users.${username} = { config, lib, ... }: {
    imports = [
          inputs.noctalia.homeModules.default
        ];

        # Configuration du fond d'écran pour Noctalia
        home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
          defaultWallpaper = "/home/${username}/Pictures/wallpaper/wallpaper.png";
        };

        programs.noctalia-shell = {
          enable = true;
          systemd.enable = true; # Auto-start avec Niri/Wayland
        };

        # Définition de la variable d'environnement pour que Noctalia lise et écrive
        # ses paramètres (dont la position des widgets) directement dans le dossier Git.
        home.sessionVariables = {
          NOCTALIA_SETTINGS_FILE = "/home/${username}/nixos-config/generated/noctalia-settings.json";
        };
  };
}
