{
  config,
  lib,
  pkgs,
  ...
}: {
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    epiphany # Web browser
    geary # Email client
    totem # Video player
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-weather
    gnome-clocks
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.just-perfection
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator
  ];
}


