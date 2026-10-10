# Music (Navidrome) and video (Jellyfin), both reading /data/media.
{lib, ...}: let
  admin = "david";
in {
  users.groups.media = {};

  systemd.tmpfiles.rules = [
    "d /data 0755 root root -"
    "d /data/media 2775 ${admin} media -"
    "d /data/media/video 2775 ${admin} media -"
  ];

  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/data/media/music";
      Address = "0.0.0.0";
      Port = 4533;
    };
  };

  # The module creates the music folder as 0700; the admin has to add files to it.
  systemd.tmpfiles.settings."10-navidrome"."/data/media/music".d = lib.mkForce {
    mode = "2775";
    user = admin;
    group = "media";
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = ["media"];
  users.users.navidrome.extraGroups = ["media"];
}
