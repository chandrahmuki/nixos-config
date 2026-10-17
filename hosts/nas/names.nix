# Our own names for the services, without port numbers: http://jellyfin.nas, http://immich.nas...
#
# Two pieces. AdGuard Home (adguard.nix) answers *.nas with the Tailscale address of the NAS
# (the devices use it as their DNS through Tailscale), and nginx, already there for Nextcloud,
# sends each name to its service. Nextcloud stays http://nas/. The phone apps keep working
# with the addresses they already have.
{...}: let
  proxy = port: {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        client_max_body_size 50000M;
      '';
    };
  };
in {
  services.nginx.virtualHosts = {
    "jellyfin.nas" = proxy 8096;
    "navidrome.nas" = proxy 4533;
    "immich.nas" = proxy 2283;
    "kavita.nas" = proxy 5000;
    "adguard.nas" = proxy 300;
  };

  # *.nas is the NAS, by its Tailscale address: it works at home and away as long as
  # Tailscale is connected. Merged over what the AdGuard page wrote (adguard.nix).
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = "*.nas";
      answer = "100.127.232.108";
      enabled = true;
    }
  ];
}
