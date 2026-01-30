{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Hack:size=12";
        terminal = "${pkgs.foot}/bin/foot"; # Lance les apps terminal dans Foot
        prompt = "'❯ '";
        layer = "overlay";
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
