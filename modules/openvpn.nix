{
  config,
  lib,
  pkgs,
  ...
}: {
  # Activer le plugin OpenVPN pour NetworkManager
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  # Installer le client openvpn en ligne de commande
  environment.systemPackages = with pkgs; [
    openvpn
  ];
}
