{ pkgs, ... }:

{
  home.packages = [ pkgs.chafa ];

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "/home/david/Pictures/nixos.png";
        type = "chafa";
        width = 22;
        height = 10;
        # On simplifie : on vire le bloc 'padding' qui cause souvent l'erreur
        # et on utilise les clés directes si ta version est très récente
        paddingTop = 1;
        paddingLeft = 1;
        paddingRight = 3;
      };
      display = {
        separator = "  ";
        color = {
          keys = "magenta";
        };
      };
      modules = [
        {
          type = "os";
          key = "OS";
        }
        {
          type = "kernel";
          key = "KR";
        }
        {
          type = "shell";
          key = "SH";
        }
        {
          type = "wm";
          key = "WM";
        }
        {
          type = "uptime";
          key = "UP";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };
}
