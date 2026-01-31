{ pkgs, ... }:

{
  # Chafa est indispensable pour le rendu terminal
  home.packages = [ pkgs.chafa ];

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "/home/david/Pictures/nixos.png";
        type = "chafa";
        # Dimensions directes (clés standards Fastfetch)
        width = 22;
        height = 10;
        # Padding structuré correctement
        padding = {
          top = 1;
          left = 1;
          right = 3;
        };
        # Paramètres spécifiques à Chafa
        chafaParams = [
          "--symbols"
          "vhalf"
          "--colors"
          "full"
          "--bg"
          "none"
        ];
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
