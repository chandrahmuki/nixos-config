{ config, hostname, ... }:

{
  programs.nh = {
    enable = true;

    # Chemin vers votre flake NixOS
    # Adaptez ce chemin selon votre configuration
    flake = "${config.home.homeDirectory}/nixos-config";

    # Nettoyage automatique des anciennes générations
    clean = {
      enable = true;
      # Garde les générations des 7 derniers jours
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  programs.fish.functions = {
    nos = ''
      cd ${config.home.homeDirectory}/nixos-config
      nh os switch . --hostname ${hostname}
    '';
  };
}
