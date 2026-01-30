{ pkgs, ... }:

{
  programs.brave = {
    enable = true;
    # On force Brave à utiliser les technologies modernes (Wayland + GPU)
    commandLineArgs = [
      "--unlimited-storage"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };
}
