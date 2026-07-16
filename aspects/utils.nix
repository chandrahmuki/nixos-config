{den, ...}: {
  den.aspects.utils.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
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
        bun
        rich-cli
        python3
        go
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
        gimp
        filezilla
        gh
        lazygit
        remmina
      ];

      programs.bat = {
        enable = true;
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
            --bind "start:reload:${pkgs.fd}/bin/fd {q} /home/${username} --exclude /nix 2>/dev/null" \
            --bind "change:reload:${pkgs.fd}/bin/fd {q} /home/${username} --exclude /nix 2>/dev/null" \
            --preview "${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {}"
        '';

        nfu = "nix flake update $argv";
      };
    };
  };

  den.aspects.muggy-nixos.includes = [den.aspects.utils];
}
