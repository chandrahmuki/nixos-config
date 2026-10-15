# Nextcloud for files, calendar and contacts, on the LAN over plain HTTP.
# Remote access goes through a VPN, not through this web server.
{pkgs, ...}: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    hostName = "nas";
    https = false;
    datadir = "/data/nextcloud";
    database.createLocally = true;
    configureRedis = true;
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      # Not in the repository: create it by hand before the first start (README.md).
      adminpassFile = "/var/lib/nextcloud-secrets/admin-pass";
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
}
