{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    xdg.configFile."cliamp/config.toml" = {
      text = ''
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
      force = true;
    };

    xdg.configFile."cliamp/radios.toml" = {
      text = ''
        [[station]]
        name = "SomaFM Groove Salad"
        url = "https://ice1.somafm.com/groovesalad-128-mp3"

        [[station]]
        name = "SomaFM Groove Salad Classic"
        url = "https://ice1.somafm.com/gsclassic-128-mp3"

        [[station]]
        name = "SomaFM Drone Zone"
        url = "https://ice1.somafm.com/dronezone-128-mp3"

        [[station]]
        name = "SomaFM Drone Zone 2"
        url = "https://ice1.somafm.com/dz2-128-mp3"

        [[station]]
        name = "SomaFM Deep Space One"
        url = "https://ice1.somafm.com/deepspaceone-128-mp3"

        [[station]]
        name = "SomaFM Space Station Soma"
        url = "https://ice1.somafm.com/spacestation-128-mp3"

        [[station]]
        name = "SomaFM Beat Blender"
        url = "https://ice1.somafm.com/beatblender-128-mp3"

        [[station]]
        name = "SomaFM Fluid"
        url = "https://ice1.somafm.com/fluid-128-mp3"

        [[station]]
        name = "SomaFM Lush"
        url = "https://ice1.somafm.com/lush-128-mp3"

        [[station]]
        name = "SomaFM The Dark Zone"
        url = "https://ice1.somafm.com/darkzone-128-mp3"

        [[station]]
        name = "SomaFM SF 10-33"
        url = "https://ice1.somafm.com/sf1033-128-mp3"

        [[station]]
        name = "SomaFM Vaporwaves"
        url = "https://ice1.somafm.com/vaporwaves-128-mp3"

        [[station]]
        name = "NTS Radio"
        url = "https://stream-relay-geo.ntslive.net/stream"

        [[station]]
        name = "Radio Paradise"
        url = "https://stream.radioparadise.com/aac-128"

        [[station]]
        name = "SomaFM DEF CON Radio"
        url = "https://ice1.somafm.com/defcon-128-mp3"

        [[station]]
        name = "SomaFM Cliqhop IDM"
        url = "https://ice1.somafm.com/cliqhop-128-mp3"

        [[station]]
        name = "SomaFM Doomed"
        url = "https://ice1.somafm.com/doomed-128-mp3"
      '';
      force = true;
    };

    home.activation.createCliampPlaylistsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/cliamp/playlists
    '';
  };
}
