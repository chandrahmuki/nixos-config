{ pkgs, ... }:
{
  home.packages = [ pkgs.chafa ];
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "/home/david/Pictures/nixos.png";
        type = "chafa";
        width = 20;
        height = 8;
        padding = {
          top = 1;
          left = 2;
          right = 4;
        };
      };
      display = {
        separator = " → ";
        color = {
          keys = "magenta";
          separator = "cyan";
        };
      };
      modules = [
        "break"
        {
          type = "os";
          key = "╭─ OS";
          format = "{3}";
        }
        {
          type = "kernel";
          key = "├─ Kernel";
        }
        {
          type = "shell";
          key = "├─ Shell";
        }
        {
          type = "wm";
          key = "├─ WM";
          format = "{1}";
        }
        {
          type = "terminal";
          key = "├─ Terminal";
        }
        {
          type = "uptime";
          key = "╰─ Uptime";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
          paddingLeft = 2;
        }
      ];
    };
  };
}
