{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
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

            # 4. Sélection de la vidéo (Affichage uniquement des titres via cut -f1)
            # On récupère l'INDEX pour mapper vers l'ID vidéo proprement
            INDEX=$(echo -e "$RESULTS" | cut -f1 | walker --dmenu --index --placeholder "Select ❯ ")

            [ -z "$INDEX" ] && exit

            # Récupération de l'ID depuis la liste originale (INDEX est 0-based)
            LINE_NUM=$((INDEX + 1))
            VIDEO_ID=$(echo -e "$RESULTS" | sed -n "''${LINE_NUM}p" | cut -f2)

            # 5. Lecture (kill sélectif — laisse mpvpaper tranquille)
            pkill -f "title=yt-player" || true

            if [ "$AUDIO_ONLY" = true ]; then
              mpv --no-video --title="yt-player" "https://www.youtube.com/watch?v=$VIDEO_ID"
            else
              mpv --title="yt-player" "https://www.youtube.com/watch?v=$VIDEO_ID"
            fi
          '')
        ];
  };
}
