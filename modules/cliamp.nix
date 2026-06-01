{ config, lib, pkgs, username, ... }:

let
  sync-playlists = pkgs.writeShellScriptBin "sync-cliamp-playlists" ''
    PLAYLISTS_DIR="$HOME/.config/cliamp/playlists"
    mkdir -p "$PLAYLISTS_DIR"

    if [ -d "$HOME/Music/Likes" ]; then
      find "$HOME/Music/Likes" -type f -name "*.m3u" | while read -r m3u_file; do
        playlist_name=$(basename "$m3u_file" .m3u | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
        toml_file="$PLAYLISTS_DIR/$playlist_name.toml"
        
        echo "Syncing playlist: $(basename "$m3u_file") -> $playlist_name.toml"
        echo -n "" > "$toml_file"
        m3u_dir=$(dirname "$m3u_file")
        
        while IFS= read -r line || [ -n "$line" ]; do
          [[ "$line" =~ ^[[:space:]]*$ ]] && continue
          [[ "$line" =~ ^# ]] && continue
          
          if [[ "$line" = /* ]]; then
            audio_path="$line"
          else
            audio_path="$m3u_dir/$line"
          fi
          
          if [ -f "$audio_path" ]; then
            filename=$(basename "$audio_path")
            title="''${filename%.*}"
            title="''${title//_/ }"
            
            cat <<EOF >> "$toml_file"
[[track]]
path = "$audio_path"
title = "$title"

EOF
          fi
        done < "$m3u_file"
      done
    fi
  '';
in
{
  home-manager.users.${username} = { config, lib, pkgs, ... }: {
    home.packages = [ sync-playlists ];

    sops.secrets.cliamp_client_id = {};
    sops.secrets.cliamp_client_secret = {};

    sops.templates."cliamp-config.toml" = {
      path = "${config.home.homeDirectory}/.config/cliamp/config.toml";
      content = ''
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
        client_id = "${config.sops.placeholder.cliamp_client_id}"
        client_secret = "${config.sops.placeholder.cliamp_client_secret}"
      '';
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
    };

    home.activation.createCliampPlaylistsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/cliamp/playlists
      $DRY_RUN_CMD ${sync-playlists}/bin/sync-cliamp-playlists
    '';
  };
}
