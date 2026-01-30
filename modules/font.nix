{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # La version "Nerd Font" de Hack (indispensable pour les icônes)
    nerd-fonts.hack
    
    # Optionnel : Emojis et polices de base si tu ne les as pas
    noto-fonts-color-emoji
    font-awesome
  ];

  # Optimisation pour le rendu des polices (plus net)
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Hack Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };
}
