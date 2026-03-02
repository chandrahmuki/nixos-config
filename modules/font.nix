{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    
    # Optionnel : Emojis et polices de base si tu ne les as pas
    noto-fonts-color-emoji
    font-awesome
  ];

  # Optimisation pour le rendu des polices (plus net)
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };
}
