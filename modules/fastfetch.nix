{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.chafa ];

  # Generate the sixel logo on activation to ensure it exists and is up to date
  home.activation.generateFastfetchLogo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p /home/david/.config/fastfetch
    ${pkgs.chafa}/bin/chafa -f sixel -s 30x14 /home/david/Pictures/nixos.png > /home/david/.config/fastfetch/logo.sixel
  '';

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "/home/david/.config/fastfetch/logo.sixel";
        type = "file-raw";
        width = 30;
        height = 14;
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
