{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    home.packages = [
          (pkgs.writeShellScriptBin "music-menu" ''
            MUSIC_DIR="$HOME/Music"
            TAB=$'\t'
            SEP="────────────────────────────────────────────────"

            # Preparation of the full list: LABEL \t PATH
            # We use a temporary file to keep the mapping while sending only labels to Walker
            (
              echo -e "󰲸  --- PLAYLISTS ---$TAB"
              find "$MUSIC_DIR" -type f -name "*.m3u" -printf "󰲸  %f$TAB%p\n" | sort
              echo -e "$SEP$TAB"
              echo -e "  --- SONGS ---$TAB"
              find "$MUSIC_DIR" -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.flac" \) -printf "  %f$TAB%p\n" | sort
            ) > /tmp/music_menu_full.list

            # Send ONLY the labels (column 1) to Walker and get the index (0-based)
            # -d is required for dmenu mode
            INDEX=$(cut -f1 /tmp/music_menu_full.list | walker -d -i -p "Music ❯ ")

            # Exit if nothing selected
            [ -z "$INDEX" ] && exit

            # Retrieve the path (column 2) from the full list at the selected index
            LINE_NUM=$((INDEX + 1))
            CHOICE=$(sed -n "''${LINE_NUM}p" /tmp/music_menu_full.list | cut -f2)

            # Exit if a separator/header is picked (empty choice)
            if [ -z "$CHOICE" ] || [ ! -f "$CHOICE" ]; then
                ${pkgs.libnotify}/bin/notify-send -t 2000 "⚠️ Music" "Selection invalide ou dossier"
                exit
            fi

            # Play with mpv using IPC socket to allow "changing" without pkill
            SOCKET="/tmp/mpv-music.sock"
            if [ -S "$SOCKET" ]; then
                # Replace current song
                echo "{\"command\": [\"loadfile\", \"$CHOICE\"]}" | ${pkgs.socat}/bin/socat - "$SOCKET"
            else
                # Start new instance
                mpv --no-video --ao=pipewire --vo=null --hwdec=no --input-ipc-server="$SOCKET" "$CHOICE" &
            fi
            ${pkgs.libnotify}/bin/notify-send -t 2000 "🎵 Musique" "$(basename "$CHOICE")"
          '')
        ];
  };
}
