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
    settings.trusted_domains = ["nas.local" "nas"];
  };

  networking.firewall.allowedTCPPorts = [80];
}
