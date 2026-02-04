{ pkgs, ... }:

{

  # 2. Les outils qu'on veut pouvoir lancer manuellement au terminal
  environment.systemPackages = with pkgs; [
    gamescope # Le micro-compositeur pour stabiliser les FPS
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

    # Optimise les performances des jeux (GameMode de Feral Interactive)
    extraPackages = with pkgs; [
      gamemode
    ];
  };

  # 4. Amélioration des performances globales (GameMode)
  # Cela permet de booster le CPU et de prioriser le GPU quand un jeu est lancé
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
      };
      gpu = {
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
