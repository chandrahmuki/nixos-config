{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "yt-search" ''
      # 1. Demander la recherche via Fuzzel
      QUERY=$(echo "" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="YouTube Search ❯ " --width=60)
      
      # Quitter si vide
      [ -z "$QUERY" ] && exit
      
      # 2. Récupérer les résultats via yt-dlp
      # On récupère le titre et l'ID séparés par une tabulation
      TAB=$'\t'
      RESULTS=$(${pkgs.yt-dlp}/bin/yt-dlp \
        --flat-playlist \
        --print "%(title)s$TAB%(id)s" \
        "ytsearch20:$QUERY")
      
      # 3. Sélectionner la vidéo via Fuzzel
      # --with-nth=1 : n'affiche que le titre
      # --accept-nth=2 : ne renvoie que l'ID
      SELECTED_ID=$(echo -e "$RESULTS" | ${pkgs.fuzzel}/bin/fuzzel \
        --dmenu \
        --prompt="Select Video ❯ " \
        --width=100 \
        --lines=20 \
        --with-nth=1 \
        --accept-nth=2 \
        --nth-delimiter="$TAB")
        
      # Quitter si rien n'est sélectionné
      [ -z "$SELECTED_ID" ] && exit
      
      # 4. Lancer la lecture avec MPV
      # On tue l'instance précédente si elle existe pour ne pas superposer le son
      ${pkgs.procps}/bin/pkill mpv || true
      
      ${pkgs.mpv}/bin/mpv "https://www.youtube.com/watch?v=$SELECTED_ID"
    '')
  ];
}
