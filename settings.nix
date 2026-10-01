{
  username = "user";
  hostname = "nixos";
  system = "x86_64-linux";
  configDirectory = "/home/user/nixos-config";
  timeZone = "UTC";
  locale = "en_US.UTF-8";

  profiles = {
    desktop = [
      "bluetooth"
      "font"
      "hyprland"
      "greetd"
      "helix"
      "thunar"
      "neovim"
      "nh"
      "screen-recording"
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
      "tealdeer"
      "xdg"
      "yazi"
    ];
    personalDesktop = [];
    personalUser = [];
    machineDesktop = [];
  };
}
