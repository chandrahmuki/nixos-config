{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    # notify-send est fourni par libnotify
        home.packages = [ pkgs.libnotify ];
        # Mako : daemon de notification léger avec support natif xdg-activation
        # Quand on clique une notification, Mako envoie un token d'activation
        # au compositeur (Niri) qui change automatiquement de workspace et focus la fenêtre
        services.mako = {
          enable = true;
          # La configuration est gérée dynamiquement par Matugen via un lien symbolique
        };

        home.file.".config/mako/config".source = config.lib.file.mkOutOfStoreSymlink "/home/${username}/nixos-config/generated/mako";
  };
}
