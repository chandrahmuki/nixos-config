{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small"; # Utilise le logo NixOS compact
        padding = {
          right = 1;
        };
      };
      display = {
        separator = " ➜ ";
        color = {
          keys = "magenta";
        };
      };
      modules = [
        "title"
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
        "colors"
      ];
    };
  };
}
