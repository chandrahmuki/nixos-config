{ _pkgs, ... }:

{
  programs.nh = {
    enable = true;

    # Chemin vers votre flake NixOS
    # Adaptez ce chemin selon votre configuration
    flake = "/home/david/nixos-config";

    # Nettoyage automatique des anciennes générations
    clean = {
      enable = true;
      # Garde les générations des 7 derniers jours
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  programs.fish.functions = {
    nos = ''
      cd /home/david/nixos-config
      nh os switch . --hostname muggy-nixos
    '';
  };
}
