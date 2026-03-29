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
            INDEX=$(cut -f1 /tmp/music_menu_full.list | walker --dmenu --index --placeholder "Music ❯ ")

            # Exit if nothing selected
            [ -z "$INDEX" ] && exit

            # Retrieve the path (column 2) from the full list at the selected index
            LINE_NUM=$((INDEX + 1))
            CHOICE=$(sed -n "''${LINE_NUM}p" /tmp/music_menu_full.list | cut -f2)

            # Exit if a separator/header is picked (empty choice)
            [ -z "$CHOICE" ] || [ ! -f "$CHOICE" ] && exit

            # Play with mpv
            ${pkgs.procps}/bin/pkill mpv || true
            mpv --no-video "$CHOICE"
          '')
        ];
  };
}
