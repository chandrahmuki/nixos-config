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

            # Debug: what did we get from walker?
            # ${pkgs.libnotify}/bin/notify-send -t 1000 "Debug" "INDEX: $INDEX"

            # Check if INDEX is a number or text
            if [[ "$INDEX" =~ ^[0-9]+$ ]]; then
                LINE_NUM=$((INDEX + 1))
                CHOICE=$(sed -n "''${LINE_NUM}p" /tmp/music_menu_full.list | cut -f2)
            else
                # Find the path matching the label exactly
                CHOICE=$(grep -F "$INDEX" /tmp/music_menu_full.list | head -n 1 | cut -f2)
            fi

            # Exit if a separator/header is picked (empty choice)
            if [ -z "$CHOICE" ] || [ ! -f "$CHOICE" ]; then
                ${pkgs.libnotify}/bin/notify-send -t 2000 "⚠️ Music" "Selection invalide ou dossier"
                exit
            fi

            # Play with selective pkill to avoid stopping other mpv instances
            pkill -f "mpv --no-video --input-ipc-server=/tmp/mpv-music.sock" || true
            mpv --no-video --ao=pipewire --vo=null --hwdec=no --input-ipc-server="/tmp/mpv-music.sock" "$CHOICE" &
            
            ${pkgs.libnotify}/bin/notify-send -t 2000 "🎵 Musique" "$(basename "$CHOICE")"
          '')
        ];
  };
}
