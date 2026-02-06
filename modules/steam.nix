{ pkgs, ... }:

{

  # 2. Les outils qu'on veut pouvoir lancer manuellement au terminal
  environment.systemPackages = with pkgs; [
    mangohud # L'overlay pour surveiller ta RX 6800 (FPS, température)
    protonup-qt # Super utile pour installer GE-Proton (indispensable sous Linux)
  ];

  # 3. La configuration du module Steam
  programs.steam = {
    enable = true;

    # Ouvre le pare-feu pour le Remote Play et les serveurs locaux
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # Active Gamescope pour pouvoir lancer une session Steam Deck
    gamescopeSession.enable = true;
  };

  # 4. Configuration globale de Gamescope (Setuid et permissions)
  programs.gamescope = {
    enable = true;
    # On peut ajouter ici des options globales si besoin
  };

  # 5. Optimise les performances des jeux (GameMode de Feral Interactive)
  # Cela permet de booster le CPU et de prioriser le GPU quand un jeu est lancé
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10; # Augmente la priorité CPU des processus de jeu
        softrealtime = "auto";
      };
      gpu = {
        # Optimisations GPU AMD (bloque la fréquence à 'high')
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}
