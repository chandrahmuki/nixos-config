{den, ...}: {
  den.aspects.backup.nixos = {
    config,
    lib,
    pkgs,
    ...
  }:
    lib.mkIf (builtins.hasAttr "/mnt/btrfs-system" config.fileSystems && builtins.hasAttr "/mnt/backup" config.fileSystems) {
      # btrbk configuration for automatic backups
      services.btrbk = {
        instances.local = {
          onCalendar = "hourly";
          settings = {
            # Snapshot name format
            timestamp_format = "long";
            # Reference day for weekly backups
            preserve_day_of_week = "monday";
            # Reference hour for daily backups
            preserve_hour_of_day = "0";

            # Always create the local snapshot even if the remote backup fails
            # This keeps the service from failing when the backup disk is full
            snapshot_create = "always";

            # BALANCED RETENTION POLICY
            # -------------------------------
            # Local snapshots (on the NVMe, for quick rollback)
            snapshot_preserve_min = "6h";
            snapshot_preserve = "6h 2d"; # On ne garde que 2 jours en local pour pas saturer

            # Backup targets (on the 447 GB SATA disk)
            target_preserve_min = "7d";
            target_preserve = "7d 4w 6m"; # On garde 6 mois d'historique ici !

            # VOLUME CONFIGURATION
            # ------------------------
            # Volume principal (NVMe)
            volume."/mnt/btrfs-system" = {
              # The subvolume to back up (a plain string avoids any ambiguity)
              subvolume = "@home";
              # Where to store the local snapshots (on the same disk)
              snapshot_dir = "@snapshots";
              # Where to send the backups (on the 447 GB disk)
              target = "/mnt/backup";
            };
          };
        };
      };

      # Service tweaks to avoid errors at boot
      systemd.services.btrbk-local = {
        # Make the service wait until the backup disk is mounted
        after = ["mnt-backup.mount" "mnt-btrfs\\x2dsystem.mount"];
        requires = ["mnt-backup.mount" "mnt-btrfs\\x2dsystem.mount"];

        unitConfig = {
          # A missing disk is not treated as a critical system error
          ConditionPathIsMountPoint = "/mnt/backup";
        };

        serviceConfig = {
          # AUTO-CLEAN: run an automatic cleanup BEFORE the backup
          # The leading "-" tells systemd to carry on even if the clean finds nothing
          ExecStartPre = [
            "-${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/local.conf clean /mnt/backup"
          ];
        };
      };

      # Keep the timer non-persistent so it does not fire at every boot
      systemd.timers.btrbk-local = {
        timerConfig.Persistent = lib.mkForce false;
      };
    };
}
