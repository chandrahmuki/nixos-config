{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    xdg.configFile."cliamp/config.toml".text = ''
      volume = 0
      repeat = "off"
      shuffle = false
      mono = false
      seek_large_step_sec = 30
      eq_preset = "Flat"
      eq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      visualizer = "Bars"
      compact = false
      theme = "Tokyo Night"
      log_level = "info"
      provider = "ytmusic"

      [ytmusic]
      client_id = ""
      client_secret = ""
    '';

    home.activation.createCliampPlaylistsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/cliamp/playlists
    '';
  };
}
