{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          top = 1;
          left = 2;
        };
      };
      display = {
        separator = "  ";
      };
      modules = [
        # Module "title" supprimé pour enlever david@muggy-nixos
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
          symbol = "circle"; # Remplace les carrés par des ronds
        }
      ];
    };
  };
}
