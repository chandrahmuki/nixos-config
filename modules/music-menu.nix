{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "music-menu" ''
      MUSIC_DIR="$HOME/Music"
      # Find playlists and songs with a hidden separator
      LISTS=$(find "$MUSIC_DIR" -type f \( -name "*.m3u" \) -printf "󰲸  Playlist: %P|%p\n" | sort)
      SONGS=$(find "$MUSIC_DIR" -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.flac" \) -printf "  Song: %P|%p\n" | sort)
      
      # Select via Fuzzel
      CHOICE=$(echo -e "$LISTS\n$SONGS" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="Music ❯ " --width=80 --lines=20)
      
      [ -z "$CHOICE" ] && exit
      
      # Extract actual full path (everything after |)
      FILE_PATH=$(echo "$CHOICE" | cut -d'|' -f2)
      
      # Play with mpv
      ${pkgs.mpv}/bin/mpv --no-video "$FILE_PATH"
    '')
  ];
}
