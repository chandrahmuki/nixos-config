# Immich: the photo and video gallery (the iPhone app backs the phone up to it), with face
# recognition and search. Nextcloud keeps the files, calendar and contacts.
#
# http://nas:2283 on the home network and through Tailscale. The first admin account is
# created in the browser on the first visit, so do that right after the first start.
{
  immichPackages,
  pkgs,
  ...
}: {
  services.immich = {
    enable = true;
    # From a newer nixpkgs than the rest of the NAS (flake.nix): the iOS app is only kept
    # working with a server of the same version.
    package = immichPackages.immich;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = false;
    mediaLocation = "/data/immich";
    # null: every other setting is edited in the web interface and kept in the database.
    settings = null;
  };

  # The photos live on the data disk: wait for it, and create the folder once it is there
  # (the module's tmpfiles rule runs before the mount and would fill the root disk).
  systemd.services.immich-server = {
    unitConfig.RequiresMountsFor = ["/data"];
    serviceConfig.ExecStartPre = "+${pkgs.coreutils}/bin/install -d -m 0700 -o immich -g immich /data/immich";
  };

  # The wired network only; Tailscale is a trusted interface already.
  networking.firewall.interfaces.eno1.allowedTCPPorts = [2283];
}
