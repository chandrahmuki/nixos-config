{ pkgs, ... }:

{
  # notify-send est fourni par libnotify
  home.packages = [ pkgs.libnotify ];
  # Mako : daemon de notification léger avec support natif xdg-activation
  # Quand on clique une notification, Mako envoie un token d'activation
  # au compositeur (Niri) qui change automatiquement de workspace et focus la fenêtre
  services.mako = {
    enable = true;
    settings = {
      # Position et apparence
      anchor = "top-right";
      layer = "top";
      width = 400;
      height = 200;
      margin = "10";
      padding = "12";
      border-size = 2;
      border-radius = 8;
      icon-path = "";
      max-icon-size = 64;

      # Couleurs Catppuccin Mocha
      background-color = "#1e1e2eee"; # Surface avec transparence
      text-color = "#cdd6f4"; # Text
      border-color = "#89b4fa"; # Blue
      progress-color = "#313244"; # Surface1

      # Comportement
      default-timeout = 5000; # 5 secondes par défaut
      ignore-timeout = false;

      # Actions : clic gauche = action par défaut (xdg-activation focus)
      # Clic droit = dismiss
      on-button-left = "invoke-default-action";
      on-button-right = "dismiss";
      on-button-middle = "dismiss-all";
    };

    # Critères spéciaux (syntaxe sections INI, pas supportée par settings)
    extraConfig = ''
      [urgency=critical]
      default-timeout=0
      border-color=#f38ba8
    '';
  };
}
