{den, ...}: {
  den.aspects.media.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: let
      syncCliampPlaylists = pkgs.writeShellScriptBin "sync-cliamp-playlists" ''
        playlists_dir="$HOME/.config/cliamp/playlists"
        mkdir -p "$playlists_dir"

        if [ -d "$HOME/Music/Likes" ]; then
          find "$HOME/Music/Likes" -type f -name "*.m3u" | while read -r m3u_file; do
            playlist_name=$(basename "$m3u_file" .m3u | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
            toml_file="$playlists_dir/$playlist_name.toml"
            : > "$toml_file"
            m3u_dir=$(dirname "$m3u_file")

            while IFS= read -r line || [ -n "$line" ]; do
              [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^# ]] && continue
              if [[ "$line" = /* ]]; then audio_path="$line"; else audio_path="$m3u_dir/$line"; fi
              if [ -f "$audio_path" ]; then
                filename=$(basename "$audio_path")
                title="''${filename%.*}"
                title="''${title//_/ }"
                cat >> "$toml_file" <<EOF
[[track]]
path = "$audio_path"
title = "$title"

EOF
              fi
            done < "$m3u_file"
          done
        fi
      '';
    in {
      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          mpris
        ];
        config = {
          hwdec = "auto-safe";
          vo = "gpu-next";
          gpu-context = "wayland";
        };
      };

      programs.yt-dlp = {
        enable = true;
        settings = {
          embed-thumbnail = true;
          add-metadata = true;
          restrict-filenames = true;
          windows-filenames = true;
          output = "%(title)s.%(ext)s";
          extractor-args = "youtube:player_client=web_embedded,web";
          cookies-from-browser = "chromium:${config.home.homeDirectory}/.config/net.imput.helium/Default";
        };
      };

      home.packages = [
        (pkgs.writeShellScriptBin "music-menu" ''
          MUSIC_DIR="$HOME/Music"
          TAB=$'\t'
          SEP="────────────────────────────────────────────────"

          (
            echo -e "󰲸  --- PLAYLISTS ---$TAB"
            find "$MUSIC_DIR" -type f -name "*.m3u" -printf "󰲸  %f$TAB%p\n" | sort
            echo -e "$SEP$TAB"
            echo -e "  --- SONGS ---$TAB"
            find "$MUSIC_DIR" -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.flac" \) -printf "  %f$TAB%p\n" | sort
          ) > "''${XDG_RUNTIME_DIR:-/tmp}/music_menu_full.list"

          INDEX=$(cut -f1 "''${XDG_RUNTIME_DIR:-/tmp}/music_menu_full.list" | walker --dmenu --placeholder "Music ❯ ")

          [ -z "$INDEX" ] && exit

          if [[ "$INDEX" =~ ^[0-9]+$ ]]; then
              LINE_NUM=$((INDEX + 1))
              CHOICE=$(sed -n "''${LINE_NUM}p" "''${XDG_RUNTIME_DIR:-/tmp}/music_menu_full.list" | cut -f2)
          else
              CHOICE=$(grep -F "$INDEX" "''${XDG_RUNTIME_DIR:-/tmp}/music_menu_full.list" | head -n 1 | cut -f2)
          fi

          if [ -z "$CHOICE" ] || [ ! -f "$CHOICE" ]; then
              ${pkgs.libnotify}/bin/notify-send -t 2000 "⚠️ Music" "Selection invalide ou dossier"
              exit
          fi

          pkill -f "title=music-player" || true
          mpv --no-video --ao=pipewire --vo=null --hwdec=no --title="music-player" "$CHOICE" &

          ${pkgs.libnotify}/bin/notify-send -t 2000 "🎵 Musique" "$(basename "$CHOICE")"
        '')

        (pkgs.writeShellScriptBin "yt-search" ''
          AUDIO_ONLY=false
          PROMPT="YouTube Video ❯ "
          [[ "$1" == "--audio" ]] && AUDIO_ONLY=true && PROMPT="YouTube Audio ❯ "

          QUERY=$(echo "" | walker --dmenu --placeholder "$PROMPT")
          [ -z "$QUERY" ] && exit

          TAB=$'\t'
          RESULTS=$(yt-dlp \
            --flat-playlist \
            --print "%(title)s$TAB%(id)s" \
            "ytsearch10:$QUERY" 2>/dev/null)

          [ -z "$RESULTS" ] && exit

          INDEX=$(echo -e "$RESULTS" | cut -f1 | walker --dmenu --placeholder "Select ❯ ")

          [ -z "$INDEX" ] && exit

          LINE_NUM=$((INDEX + 1))
          VIDEO_ID=$(echo -e "$RESULTS" | sed -n "''${LINE_NUM}p" | cut -f2)

          pkill -f "title=music-player" || true

          if [ "$AUDIO_ONLY" = true ]; then
            mpv --no-video --title="music-player" "https://www.youtube.com/watch?v=$VIDEO_ID"
          else
            mpv --title="music-player" "https://www.youtube.com/watch?v=$VIDEO_ID"
          fi
        '')

        pkgs.cliamp
        syncCliampPlaylists
      ];

      xdg.configFile."cliamp/radios.toml".source = ../assets/cliamp-radios.toml;

      home.activation.createCliampPlaylistsDir = config.lib.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/cliamp/playlists
        $DRY_RUN_CMD ${syncCliampPlaylists}/bin/sync-cliamp-playlists 2>/dev/null || true
      '';

      programs.fish.functions = {
        yt = "yt-dlp -x --audio-format m4a $argv";

        mpno = ''
          set -l SOCKET /tmp/mpv-music.sock
          set -l FILE $argv[1]
          if test -S $SOCKET
              echo "{\"command\": [\"loadfile\", \"$FILE\"]}" | ${pkgs.socat}/bin/socat - $SOCKET
          else
              mpv --no-video --ao=pipewire --vo=null --hwdec=no --input-ipc-server=$SOCKET "$FILE" &
              disown
          end
          ${pkgs.libnotify}/bin/notify-send -t 2000 "🎵 Musique" (basename "$FILE")
        '';

        mkpl = ''
          set -l name (if test (count $argv) -gt 0; echo $argv[1]; else; echo "playlist.m3u"; end)
          ${pkgs.fd}/bin/fd --max-depth 1 -e mp3 -e flac -e m4a -e wav -e ogg . > $name
          echo "✅ Playlist created in current dir: $name"
        '';
      };
    };
  };

}
