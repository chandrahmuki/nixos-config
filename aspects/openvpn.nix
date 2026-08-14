{den, ...}: {
  den.aspects.openvpn.nixos = {pkgs, ...}: {
    networking.networkmanager.plugins = [pkgs.networkmanager-openvpn];
    environment.systemPackages = [pkgs.openvpn];
  };

}
