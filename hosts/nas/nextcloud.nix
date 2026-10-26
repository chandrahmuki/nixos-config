# Nextcloud for files, calendar and contacts, on the LAN over plain HTTP.
# Remote access goes through a VPN, not through this web server.
{
  config,
  pkgs,
  ...
}: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    hostName = "nas";
    https = false;
    datadir = "/data/nextcloud";
    database.createLocally = true;
    configureRedis = true;

    # Thumbnails. Nextcloud makes them on demand, the first time a folder is opened, and
    # only for the formats it is told about: the defaults have no video and no HEIC (the
    # iPhone's photo format). Movie needs ffmpeg, HEIC needs Imagick.
    phpExtraExtensions = all: [all.imagick];
    extraApps = {inherit (config.services.nextcloud.package.packages.apps) previewgenerator;};
    extraAppsEnable = true;
    config = {
      dbtype = "pgsql";
    };
    settings = {
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\Movie"
      ];
      preview_ffmpeg_path = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      preview_ffprobe_path = "${pkgs.ffmpeg-headless}/bin/ffprobe";
    };
    # Every address the NAS answers to: its names on the home network, its address there
    # (the router hands it out, so it can change) and its Tailscale name and address.
    settings.trusted_domains = [
      "nas"
      "nas.local"
      "nas.fritz.box"
      "192.168.178.34"
      "nas.tailbc7882.ts.net"
      "100.127.232.108"
    ];
  };

  networking.firewall.allowedTCPPorts = [80];

  # Preview Generator makes the thumbnails of new files in the background, every 10 minutes,
  # so they are ready when a folder is opened. The files that were there before it was
  # enabled need one `nextcloud-occ preview:generate-all` (README.md).
  systemd.services.nextcloud-preview-pregenerate = {
    description = "Pre-generate Nextcloud thumbnails";
    after = ["phpfpm-nextcloud.service"];
    requires = ["phpfpm-nextcloud.service"];
    unitConfig.RequiresMountsFor = ["/data"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.services.nextcloud.occ}/bin/nextcloud-occ preview:pre-generate";
    };
  };
  systemd.timers.nextcloud-preview-pregenerate = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "10min";
    };
  };
}
