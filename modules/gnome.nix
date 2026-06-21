{
  config,
  lib,
  pkgs,
  username,
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
    gnomeExtensions.user-themes
  ];

  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = with pkgs.gnomeExtensions; [
          appindicator.extensionUuid
          blur-my-shell.extensionUuid
          dash-to-dock.extensionUuid
          just-perfection.extensionUuid
          caffeine.extensionUuid
          clipboard-indicator.extensionUuid
          user-themes.extensionUuid
        ];
      };
    };
  };
}


