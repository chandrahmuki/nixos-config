#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
out_dir="quickshell/assets/wallpapers"
logo="quickshell/assets/muggynix-logo.png"
command -v magick >/dev/null
[[ -s "$logo" ]]

# id|background|surface|accent
while IFS='|' read -r id bg surface accent; do
  [[ -n "$id" ]] || continue
  target="$out_dir/muggynix-$id.jpg"
  magick -size 2560x1440 "gradient:$bg-$surface" \
    -fill none -stroke "#${accent#\#}55" -strokewidth 3 \
    -draw 'path "M -120,1130 C 480,1030 420,390 1120,360 S 1840,1150 2700,710"' \
    -stroke "#${accent#\#}30" -strokewidth 2 \
    -draw 'path "M -80,1230 C 580,1120 540,500 1190,460 S 1950,1250 2700,820"' \
    -fill '#10131be8' -stroke "#${accent#\#}90" -strokewidth 2 \
    -draw 'roundrectangle 735,1170 1825,1390 34,34' \
    \( "$logo" -resize 920x \) -gravity south -geometry +0+90 -compose over -composite \
    -sampling-factor 4:2:0 -quality 92 "$target"
done <<'PALETTES'
flexoki-light|#FFFCF0|#E6E4D9|#205EA6
lupine|#fafafa|#f5f5f5|#3264eb
rose-pine|#faf4ed|#f2e9e1|#56949f
PALETTES
