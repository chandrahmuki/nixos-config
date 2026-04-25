{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      home.packages = with pkgs; [
        fd
        dust
        gdu
        ncdu
        playerctl
        manix
        pamixer
        pavucontrol
        pulseaudio
        nodejs
        rich-cli
        python3
        repomix
        qpdf
        jq
        matugen
        uv
        cava
        ddcutil
        brightnessctl
        aria2
        lftp
      ];

      programs.bat = {
        enable = true;
        config = {
          theme = "Dracula";
        };
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.fish.functions = {
        md = "rich --markdown $argv";

        search = ''
          if test (count $argv) -eq 0
            echo "Usage: search <query>"
            return 1
          end

          ${pkgs.fzf}/bin/fzf --disabled --query "$argv" \
            --bind "start:reload:${pkgs.fd}/bin/fd {q} / 2>/dev/null" \
            --bind "change:reload:${pkgs.fd}/bin/fd {q} / 2>/dev/null" \
            --preview "${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {}"
        '';

        nfu = "nix flake update $argv";
      };
    };
}
