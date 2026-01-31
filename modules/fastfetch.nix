{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "/home/david/Pictures/nixos.png"; # <--- METS TON CHEMIN ICI
        type = "kitty-direct"; # Protocole image pour Foot
        width = 28;
        height = 12;
        padding = {
          top = 1;
          left = 2;
          right = 4;
        };
      };
      display = {
        separator = "  ";
      };
      modules = [
        # "title" supprimé pour cacher david@muggy-nixos
        {
          type = "os";
          key = "OS";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "KR";
          keyColor = "magenta";
        }
        {
          type = "shell";
          key = "SH";
          keyColor = "yellow";
        }
        {
          type = "wm";
          key = "WM";
          keyColor = "cyan";
        }
        {
          type = "uptime";
          key = "UP";
          keyColor = "green";
        }
        "break"
        {
          type = "colors";
          symbol = "circle"; # Tes petits points de couleur
        }
      ];
    };
  };
}
