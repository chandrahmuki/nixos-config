# The second part of the WD 2 TB disk (formerly NTFS with old data, now btrfs and empty), for
# the films and the series: the same layout as /data/media/video (Movies and Shows). Mounted
# on /video2, outside /data on purpose: the nightly backup copies /data and the films are not
# part of it.
#
# In Jellyfin, add /video2/Movies to the Movies library and /video2/Shows to the Shows library
# (a library can have several folders).
{pkgs, ...}: {
  # nofail: the NAS still boots without this partition, Jellyfin just does not see these films.
  fileSystems."/video2" = {
    device = "/dev/disk/by-uuid/45240ba6-160a-4ed1-ade0-fe4c95e5c9a7";
    fsType = "btrfs";
    # No compression: films are already compressed.
    options = ["noatime" "nofail" "x-systemd.device-timeout=10s"];
  };

  # Jellyfin reads through the media group; the admin writes. Made once /video2 is mounted.
  systemd.services.video2-folders = {
    description = "Create the film folders on /video2";
    wantedBy = ["jellyfin.service"];
    before = ["jellyfin.service"];
    unitConfig.RequiresMountsFor = ["/video2"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      install -d -m 2775 -o david -g media /video2 /video2/Movies /video2/Shows
    '';
    path = [pkgs.coreutils];
  };
}
