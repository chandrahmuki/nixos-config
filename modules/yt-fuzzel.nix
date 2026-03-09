{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "yt-search" ''
      # 1. Mode de lecture (Audio ou Vidéo)
      AUDIO_ONLY=false
      PROMPT="YouTube Video ❯ "
      [[ "$1" == "--audio" ]] && AUDIO_ONLY=true && PROMPT="YouTube Audio ❯ "

      # 2. Recherche via Walker dmenu
      QUERY=$(echo "" | walker --dmenu --placeholder "$PROMPT")
      [ -z "$QUERY" ] && exit
      
      # 3. Récupérer les résultats via yt-dlp
      TAB=$'\t'
      RESULTS=$(yt-dlp \
        --flat-playlist \
        --print "%(title)s$TAB%(id)s" \
        "ytsearch10:$QUERY" 2>/dev/null)
      
      [ -z "$RESULTS" ] && exit

      # 4. Sélection de la vidéo
      SELECTED=$(echo -e "$RESULTS" | walker --dmenu --placeholder "Select ❯ ")
      [ -z "$SELECTED" ] && exit
      VIDEO_ID=$(echo "$SELECTED" | cut -f2)
      
      # 5. Lecture (kill précédent)
      ${pkgs.procps}/bin/pkill mpv || true
      
      if [ "$AUDIO_ONLY" = true ]; then
        mpv --no-video "https://www.youtube.com/watch?v=$VIDEO_ID"
      else
        mpv "https://www.youtube.com/watch?v=$VIDEO_ID"
      fi
    '')
  ];
}
