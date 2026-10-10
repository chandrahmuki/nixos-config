# Remote access from the phone or any laptop: join the NAS to a Tailscale network
# instead of opening ports on the router. The login is done by hand on the machine
# (README.md), so no key lives in this repository.
{
  services.tailscale.enable = true;

  # The services are reached over the tailnet, which is already encrypted.
  networking.firewall.trustedInterfaces = ["tailscale0"];
}
