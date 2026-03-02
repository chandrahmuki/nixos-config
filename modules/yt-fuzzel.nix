{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "yt-search" ''
      # Vérifier si on est en mode audio seul
      AUDIO_ONLY=false
      [[ "$1" == "--audio" ]] && AUDIO_ONLY=true

      # 1. Demander la recherche via Fuzzel
      PROMPT="YouTube Search ❯ "
      [[ "$AUDIO_ONLY" == "true" ]] && PROMPT="YouTube Audio ❯ "

      QUERY=$(echo "" | walker --dmenu --placeholder "$PROMPT")
      
      # Quitter si vide
      [ -z "$QUERY" ] && exit
      
      # 2. Récupérer les résultats via yt-dlp
      TAB=$'\t'
      RESULTS=$(${pkgs.yt-dlp}/bin/yt-dlp \
        --flat-playlist \
        --print "%(title)s$TAB%(id)s" \
        "ytsearch20:$QUERY")
      
      # 3. Sélectionner la vidéo
      SELECTED_ID=$(echo -e "$RESULTS" | walker --dmenu \
        --placeholder "Select ❯ ")
        
      [ -z "$SELECTED_ID" ] && exit
      
      # 4. Lancer la lecture
      ${pkgs.procps}/bin/pkill mpv || true
      
      MPV_FLAGS=""
      [[ "$AUDIO_ONLY" == "true" ]] && MPV_FLAGS="--no-video"
      
      mpv $MPV_FLAGS "https://www.youtube.com/watch?v=$SELECTED_ID"
    '')
  ];
}
