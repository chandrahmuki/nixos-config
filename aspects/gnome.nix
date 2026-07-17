{den, ...}: {
  den.aspects.gnome.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    services.desktopManager.gnome.enable = true;

    environment.sessionVariables = {
      MUTTER_DEBUG_FORCE_DISABLE_DIRECT_SCANOUT = "1";
    };

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
      gnomeExtensions.gnome-wallpaper-engine
      gnomeExtensions.switch-workspaces-on-active-monitor
    ];

    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      dconf.settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          disable-extension-version-validation = true;
          enabled-extensions = with pkgs.gnomeExtensions; [
            appindicator.extensionUuid
            blur-my-shell.extensionUuid
            dash-to-dock.extensionUuid
            just-perfection.extensionUuid
            caffeine.extensionUuid
            clipboard-indicator.extensionUuid
            user-themes.extensionUuid
            gnome-wallpaper-engine.extensionUuid
            switch-workspaces-on-active-monitor.extensionUuid
          ];
        };
        "org/gnome/mutter" = {
          experimental-features = ["scale-monitor-framebuffer" "xwayland-native-scaling"];
          workspaces-only-on-primary = false;
          dynamic-workspaces = true;
        };
        "org/gnome/desktop/wm/keybindings" = {
          show-desktop = []; # Libère Super+D qui masque le bureau par défaut
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>d";
          command = "walker";
          name = "Walker Launcher";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Super>t";
          command = "foot";
          name = "Terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          binding = "<Super>b";
          command = "nautilus";
          name = "File Manager";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          binding = "<Super>h";
          command = "helium";
          name = "Helium Browser";
        };
      };
    };
  };

  den.aspects.muggy-nixos.includes = [den.aspects.gnome];
}
