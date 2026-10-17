# AdGuard Home: a DNS server for the home. It blocks the ads and the trackers for every
# device that uses it, and it can answer with our own names (DNS rewrites).
#
# http://nas:300 on the home network and through Tailscale (the setup wizard kept 300 as the
# port of this page, and the file it wrote wins over the option below; 53 is the DNS port).
# Everything else (filters, rewrites) is edited in that page and kept in /var/lib/AdGuardHome.
#
# The devices use it by Tailscale (Tailscale admin console, DNS, add the Tailscale address of
# the NAS as a nameserver) or by the router's DNS setting; nothing here changes the router.
{...}: {
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 300;
    openFirewall = false;
    mutableSettings = true;
  };

  # The wired network only; Tailscale is a trusted interface already.
  networking.firewall.interfaces.eno1 = {
    allowedTCPPorts = [53 300];
    allowedUDPPorts = [53];
  };
}
