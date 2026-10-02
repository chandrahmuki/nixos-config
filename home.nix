{
  username,
  hostname,
  settings,
  config,
  lib,
  ...
}: {
  # User profile and home directory
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Initial Home Manager state version (do not change)
  home.stateVersion = "25.11";
  home.sessionVariables = {
    NIXOS_CONFIG_DIR = settings.configDirectory;
    NIXOS_CONFIG_HOST = hostname;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # GTK4 follows the global GTK theme. Setting it keeps the legacy behaviour and
  # silences the Home Manager 26.05 warning.
  gtk.gtk4.theme = lib.mkDefault config.gtk.theme;

  # Export the default XDG user directories (Downloads, Music, etc.) in the session
  xdg.userDirs.setSessionVariables = true;
}
