{ pkgs, ... }:

{
  # Installation de Vesktop (client Discord alternatif optimisé pour Wayland)
  home.packages = with pkgs; [
    vesktop # Supporte le partage d'écran audio/vidéo sous Wayland et inclut Vencord
  ];
}
