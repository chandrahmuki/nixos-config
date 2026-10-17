# Nightly backup of the NAS onto its own disk (Toshiba 1 TB, label "backup", btrfs).
#
# Each night /data (photos, Drive, music, books, manga, shared folder), the databases of
# Nextcloud and Immich, and the settings of Jellyfin, Navidrome and Kavita are copied to
# /backup/current, then a read-only btrfs snapshot keeps that night: the 30 newest are kept,
# so a file deleted by mistake can be taken back from an older night. The thumbnails and the
# re-encoded videos of Immich are not copied: it makes them again. Nor are the films
# (/data/media/video): they can be downloaded again.
#
# A backup on the same machine does not protect against a fire, a theft or a power surge:
# keep another copy of what matters somewhere else (README.md).
{
  config,
  pkgs,
  ...
}: let
  pgBin = "${config.services.postgresql.package}/bin";
  nasBackup = pkgs.writeShellApplication {
    name = "nas-backup";
    runtimeInputs = [pkgs.rsync pkgs.btrfs-progs pkgs.coreutils pkgs.util-linux pkgs.findutils];
    text = ''
      # Never sync from a disk that is not there: an empty /data would empty the backup.
      mountpoint -q /backup || { echo "the backup disk is not mounted"; exit 1; }
      mountpoint -q /data || { echo "the data disk is not mounted"; exit 1; }
      [ -d /data/immich ] && [ -d /data/nextcloud ] || { echo "the data folders are missing, not syncing"; exit 1; }

      [ -d /backup/current ] || btrfs subvolume create /backup/current
      mkdir -p /backup/snapshots /backup/current/data /backup/current/system /backup/current/db

      for db in nextcloud immich; do
        runuser -u postgres -- ${pgBin}/pg_dump -Fc "$db" > "/backup/current/db/$db.dump.tmp"
        mv "/backup/current/db/$db.dump.tmp" "/backup/current/db/$db.dump"
      done

      # The films are not copied (they can be downloaded again, and they are big): excluded
      # files are also removed from the copy, so nothing about them stays there.
      rsync -aH --delete --delete-excluded --numeric-ids \
        --exclude=/immich/thumbs --exclude=/immich/encoded-video --exclude=/media/video \
        /data/ /backup/current/data/
      for d in jellyfin navidrome kavita; do
        if [ -d "/var/lib/$d" ]; then
          rsync -aH --delete --numeric-ids "/var/lib/$d/" "/backup/current/system/$d/"
        fi
      done

      btrfs subvolume snapshot -r /backup/current "/backup/snapshots/$(date +%Y-%m-%d_%H%M)"
      # Keep the 30 newest nights.
      find /backup/snapshots -mindepth 1 -maxdepth 1 -type d | sort | head -n -30 | while read -r old; do
        btrfs subvolume delete "$old"
      done
      echo "backup done: $(du -sh /backup/current | cut -f1) in /backup/current"
    '';
  };
in {
  # nofail: the NAS still boots without this disk, the services just have no backup.
  fileSystems."/backup" = {
    device = "/dev/disk/by-uuid/ca01062a-5bc8-42f1-86ef-15600cc5033d";
    fsType = "btrfs";
    options = ["compress=zstd:3" "noatime" "nofail" "x-systemd.device-timeout=10s"];
  };

  environment.systemPackages = [nasBackup];

  systemd.services.nas-backup = {
    description = "Nightly backup of the NAS";
    unitConfig.RequiresMountsFor = ["/data" "/backup"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${nasBackup}/bin/nas-backup";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.timers.nas-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 03:30:00";
      Persistent = true;
    };
  };
}
