dir="$HOME/Pictures/Screenshots"

selection=$(slurp) || exit 0
[ -n "$selection" ] || exit 0

mkdir -p "$dir"
file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"
grim -g "$selection" "$file"
wl-copy --type image/png <"$file"

# The shell opens the first link of a notification when its card is clicked;
# the folder opens in the default file manager (Thunar).
notify-send --app-name=Screenshot --icon="$file" -t 6000 Capture \
  "Copiée et enregistrée : $(basename "$file") · <a href=\"file://$dir\">Ouvrir le dossier</a>"
