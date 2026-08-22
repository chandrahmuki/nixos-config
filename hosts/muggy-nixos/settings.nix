{
  username = "david";
  userEmail = "amouyaljerome@gmail.com";
  hostname = "muggy-nixos";
  system = "x86_64-linux";
  configDirectory = "/home/david/nixos-config";
  timeZone = "Europe/Vienna";
  locale = "de_AT.UTF-8";

  profiles = {
    desktop = [
      "bluetooth"
      "font"
      "gnome"
      "hyprland"
      "greetd"
      "helix"
      "nautilus"
      "neovim"
      "nh"
      "stylix"
      "terminal"
      "theme"
      "utils"
      "vscode"
      "walker"
    ];
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
