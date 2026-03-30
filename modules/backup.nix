{ config, lib, pkgs, ... }:

{
  # Configuration de btrbk pour les backups automatiques
  services.btrbk = {
    instances.local = {
      onCalendar = "hourly";
      settings = {
        # Format des noms de snapshots
        timestamp_format = "long";
        # Jour de référence pour les backups hebdomadaires
        preserve_day_of_week = "monday";
        # Heure de référence pour les backups quotidiens
        preserve_hour_of_day = "0";

        # Toujours créer le snapshot local même si le backup distant échoue
        # Cela évite que le service s'arrête en erreur si le disque de backup est plein
        snapshot_create = "always";

        # POLITIQUE DE RÉTENTION ÉQUILIBRÉE
        # -------------------------------
        # Snapshots locaux (sur le NVMe, pour rollback rapide)
        snapshot_preserve_min = "6h";
        snapshot_preserve = "6h 2d"; # On ne garde que 2 jours en local pour pas saturer

        # Backups cibles (sur le disque SATA de 447 Go)
        target_preserve_min = "7d";
        target_preserve = "7d 4w 6m"; # On garde 6 mois d'historique ici !

        # CONFIGURATION DES VOLUMES
        # ------------------------
        # Volume principal (NVMe)
        volume."/mnt/btrfs-system" = {
          # Le subvolume à sauvegarder (on utilise une chaîne brute pour éviter toute confusion)
          subvolume = "@home";
          # Où stocker les snapshots locaux (sur le même disque)
          snapshot_dir = "@snapshots";
          # Où envoyer les backups (sur le disque de 447 Go)
          target = "/mnt/backup";
        };
      };
    };
  };

  # Correction du comportement du service pour éviter les erreurs au boot
  systemd.services.btrbk-local = {
    # On force le service à attendre que le disque de backup soit monté
    after = [ "mnt-backup.mount" "mnt-btrfs\\x2dsystem.mount" ];
    requires = [ "mnt-backup.mount" "mnt-btrfs\\x2dsystem.mount" ];
    
    unitConfig = {
      # Si le disque n'est pas là, on ne considère pas ça comme une erreur critique du système
      ConditionPathIsMountPoint = "/mnt/backup";
    };

    serviceConfig = {
      # AUTO-CLEAN : On lance un nettoyage automatique AVANT le backup
      # Le "-" au début dit à systemd de continuer même si le clean ne trouve rien
      ExecStartPre = [
        "-${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/local.conf clean /mnt/backup"
      ];
    };
  };

  # On garde le timer non-persistant pour ne pas spammer au boot
  systemd.timers.btrbk-local = {
    timerConfig.Persistent = lib.mkForce false;
  };
}
