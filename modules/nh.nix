{
  config,
  lib,
  pkgs,
  username,
  hostname,
  ...
}:

{
  programs.nh = {
    enable = true;

    # Chemin vers votre flake NixOS
    # Adaptez ce chemin selon votre configuration
    flake = "/home/${username}/nixos-config";

    # Nettoyage automatique des anciennes générations
    clean = {
      enable = true;
      # Garde les générations des 7 derniers jours
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  home-manager.users.${username} = { config, lib, ... }: {
    programs.fish.functions = {
      nos = ''
        cd /home/${username}/nixos-config
        nh os switch . --hostname ${hostname} --ask -L --diff always
      '';
    };
  };
}
