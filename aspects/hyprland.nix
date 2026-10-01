{den, ...}: {
  den.aspects.hyprland.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Needed for screen sharing and file pickers in the Hyprland session.
    xdg.portal = {
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      config.hyprland.default = ["hyprland" "gtk"];
    };

    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: let
      wallpaper = ../wallpapers/nixos_neon_souterrain.png;
      gnomeLinesWallpaper = ../wallpapers/gnome_00_2560x1440.png;
      gnomeGradientWallpaper = ../wallpapers/wallpaperGnome.png;
      muggynixWallpaperDir = ../quickshell/assets/wallpapers;
      muggyTheme = pkgs.writeShellApplication {
        name = "muggy-theme";
        runtimeInputs = [pkgs.hyprland pkgs.coreutils pkgs.glib pkgs.jq pkgs.kitty pkgs.matugen pkgs.papirus-folders];
        text = builtins.replaceStrings ["@gnomeGradientWallpaper@" "@gnomeLinesWallpaper@" "@muggynixWallpaperDir@" "@wallpaper@"] ["${gnomeGradientWallpaper}" "${gnomeLinesWallpaper}" "${muggynixWallpaperDir}" "${wallpaper}"] (builtins.readFile ../files/hyprland/muggy-theme.sh);
      };
      restartQuickshell = pkgs.writeShellApplication {
        name = "restart-quickshell";
        runtimeInputs = [pkgs.quickshell pkgs.gnugrep pkgs.coreutils];
        text = builtins.readFile ../files/hyprland/restart-quickshell.sh;
      };
      localWorkspace = pkgs.writeShellApplication {
        name = "local-workspace";
        runtimeInputs = [pkgs.hyprland pkgs.jq];
        text = builtins.readFile ../files/hyprland/local-workspace.sh;
      };
    in {
      home.packages = [
        restartQuickshell
        localWorkspace
        muggyTheme
        pkgs.grim
        pkgs.slurp
        pkgs.wl-clipboard
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        # The actual Lua file is managed below through xdg.configFile.
        # Keep Home Manager's empty legacy file explicit to avoid a stateVersion
        # warning and to prevent it from competing for hyprland.lua.
        configType = "hyprlang";
        # UWSM owns the session lifecycle; a second Home Manager systemd
        # integration would race it.
        systemd.enable = false;
      };

      programs.quickshell = {
        enable = true;
        activeConfig = "muggy";
        # Hyprland starts the shell below, only in its own session.
        systemd.enable = false;
      };

      # Development configuration: keep the active QML as a direct link to
      # this checkout so Quickshell can observe edits and hot-reload them.
      # The link itself remains declared by Home Manager.
      xdg.configFile."quickshell/muggy".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-config/quickshell";

      programs.hyprlock.enable = true;

      # No hyprpaper: the wallpaper is Quickshell's own BackgroundWindow now
      # (windows/BackgroundWindow.qml), so theme transitions can animate it
      # directly instead of fighting a second client for the Background
      # layer — that fight is exactly why hyprpaper was here before, and why
      # its reveal effect never reliably showed up on top of it.
      #
      # Removing our own `services.hyprpaper` block wasn't the whole story:
      # Stylix provisions hyprpaper on its own too (it wires up whatever
      # wallpaper daemon fits the session so `stylix.image` gets applied),
      # entirely independent of that block. That's the actual reason the
      # unit kept reappearing after every switch — disabled explicitly here,
      # same as the other per-app Stylix targets below.
      stylix.targets.hyprpaper.enable = lib.mkForce false;
      # The target flag above only stops Stylix from *configuring*
      # hyprpaper's wallpaper — Stylix's hyprpaper target still turns on
      # home-manager's own `services.hyprpaper` regardless, which is what
      # actually creates the systemd unit. Force that off too.
      services.hyprpaper.enable = lib.mkForce false;

      # Hypridle performs the security-sensitive idle policy; Quickshell only
      # provides the shell UI and can invoke `hyprlock` from a future menu.
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 600;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 900;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

      # Keep this short and explicit.  The scroll layout is native in the
      # installed Hyprland; no version-locked layout plugin is involved.
      xdg.configFile."hypr/hyprland.lua".text = builtins.replaceStrings ["@homeDirectory@" "@fish@" "@kitty@" "@libnotify@"] ["${config.home.homeDirectory}" "${pkgs.fish}" "${pkgs.kitty}" "${pkgs.libnotify}"] (builtins.readFile ../files/hyprland/hyprland.lua);
    };
  };
}
