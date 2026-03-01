{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "yt-search" ''
      # Vérifier si on est en mode audio seul
      AUDIO_ONLY=false
      [[ "$1" == "--audio" ]] && AUDIO_ONLY=true

      # 1. Demander la recherche via Fuzzel
      PROMPT="YouTube Search ❯ "
      [[ "$AUDIO_ONLY" == "true" ]] && PROMPT="YouTube Audio ❯ "

      QUERY=$(echo "" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="$PROMPT" --width=60)
      
      # Quitter si vide
      [ -z "$QUERY" ] && exit
      
      # 2. Récupérer les résultats via yt-dlp
      TAB=$'\t'
      RESULTS=$(${pkgs.yt-dlp}/bin/yt-dlp \
        --flat-playlist \
        --print "%(title)s$TAB%(id)s" \
        "ytsearch20:$QUERY")
      
      # 3. Sélectionner la vidéo
      SELECTED_ID=$(echo -e "$RESULTS" | ${pkgs.fuzzel}/bin/fuzzel \
        --dmenu \
        --prompt="Select ❯ " \
        --width=100 \
        --lines=20 \
        --with-nth=1 \
        --accept-nth=2 \
        --nth-delimiter="$TAB")
        
      [ -z "$SELECTED_ID" ] && exit
      
      # 4. Lancer la lecture
      ${pkgs.procps}/bin/pkill mpv || true
      
      MPV_FLAGS=""
      [[ "$AUDIO_ONLY" == "true" ]] && MPV_FLAGS="--no-video"
      
      mpv $MPV_FLAGS "https://www.youtube.com/watch?v=$SELECTED_ID"
    '')
  ];
}
