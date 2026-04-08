{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
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

          INDEX=$(cut -f1 "''${XDG_RUNTIME_DIR:-/tmp}/music_menu_full.list" | walker -d -i -p "Music ❯ ")

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

          INDEX=$(echo -e "$RESULTS" | cut -f1 | walker --dmenu --index --placeholder "Select ❯ ")

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
      ];

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
}
