{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "music-menu" ''
      MUSIC_DIR="$HOME/Music"
      
      # Headers (for visual organization)
      SEP="────────────────────────────────────────────────"
      
      # Find playlists (Display name | Full path)
      LISTS=$(find "$MUSIC_DIR" -type f \( -name "*.m3u" \) -printf "󰲸  %f|%p\n" | sort)
      
      # Find songs (Display name | Full path)
      SONGS=$(find "$MUSIC_DIR" -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.flac" \) -printf "  %f|%p\n" | sort)
      
      # Construct the menu content
      MENU_CONTENT="󰲸  --- PLAYLISTS ---|IGNORE\n$LISTS\n$SEP|IGNORE\n  --- SONGS ---|IGNORE\n$SONGS"
      
      # Select via Fuzzel
      CHOICE=$(echo -e "$MENU_CONTENT" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="Music ❯ " --width=100 --lines=25)
      
      # Exit if nothing selected or if a separator/header is picked
      [ -z "$CHOICE" ] || [[ "$CHOICE" == *"---"* ]] || [[ "$CHOICE" == *"────"* ]] && exit
      
      # Extract actual full path (everything after |)
      FILE_PATH=$(echo "$CHOICE" | cut -d'|' -f2)
      
      # Play with mpv
      ${pkgs.mpv}/bin/mpv --no-video "$FILE_PATH"
    '')
  ];
}
