{ pkgs, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
  ];

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font:size=18";
        terminal = "${pkgs.ghostty}/bin/ghostty";
        prompt = "'❯ '";
        layer = "overlay";
        icons-enabled = "yes";
        icon-theme = "Papirus-Dark";
        width = 40;
        lines = 15;
      };

      colors = {
        background = "1a1b26ff"; # Sombre (Tokyo Night style)
        text = "c0caf5ff";
        match = "bb9af7ff"; # Couleur des lettres filtrées
        selection = "33467cff";
        selection-text = "ffffffff";
        border = "bb9af7ff";
      };

      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
