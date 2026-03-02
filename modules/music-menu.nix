{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "music-menu" ''
      MUSIC_DIR="$HOME/Music"
      TAB=$'\t'
      
      # Find playlists (Display name \t Full path)
      LISTS=$(find "$MUSIC_DIR" -type f -name "*.m3u" -printf "󰲸  %f$TAB%p\n" | sort)
      
      # Find songs (Display name \t Full path)
      SONGS=$(find "$MUSIC_DIR" -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.flac" \) -printf "  %f$TAB%p\n" | sort)
      
      # Construct the menu content
      SEP="────────────────────────────────────────────────"
      MENU_CONTENT="󰲸  --- PLAYLISTS ---$TAB\n$LISTS\n$SEP$TAB\n  --- SONGS ---$TAB\n$SONGS"
      
      # Select via Walker
      CHOICE=$(echo -e "$MENU_CONTENT" | walker --dmenu --placeholder "Music ❯ " | cut -f2)
      
      # Exit if nothing selected or if a separator/header is picked (check if it's a valid file)
      [ -z "$CHOICE" ] || [ ! -f "$CHOICE" ] && exit
      
      # Play with mpv (kill previous instance first to avoid parallel playback)
      ${pkgs.procps}/bin/pkill mpv || true
      mpv --no-video "$CHOICE"
    '')
  ];
}
