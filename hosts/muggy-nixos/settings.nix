let
  # Everything not overridden here comes from the public settings, so the
  # shared profile lists cannot drift apart.
  base = import ../../settings.nix;
in
  base
  // {
    username = "david";
    userEmail = "amouyaljerome@gmail.com";
    hostname = "muggy-nixos";
    configDirectory = "/home/david/nixos-config";
    timeZone = "Europe/Vienna";
    locale = "de_AT.UTF-8";

    profiles =
      base.profiles
      // {
        user = [
          "btop"
          "direnv"
          "git"
          "microfetch"
          "notifications"
          "sops"
          "tealdeer"
          "xdg"
          "yazi"
        ];
        personalDesktop = [
          "ai"
          "chatgpt"
          "gaming"
          "handbrake"
          "irc"
          "media"
          "openvpn"
          "performance-tuning"
          "qmk"
        ];
        personalUser = [
          "discord"
          "helium"
          "herdr"
          "obsidian"
          "oculante"
          "parsec"
          "pdf"
          "zen-browser"
        ];
        machineDesktop = [
          "machine-storage"
          "backup"
        ];
      };
  }
