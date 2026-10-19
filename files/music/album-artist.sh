#!/usr/bin/env bash
# Gives every track of a downloaded album the same album_artist tag.
# YouTube Music tags each track with its own artists and no album artist, so Navidrome
# splits one album into many (one per artist combination). The album artist chosen is the
# artists present on every track ("Various Artists" when there are none).
# usage: album-artist FILE_WITH_ONE_PATH_PER_LINE
set -u
list=$1
declare -A tracks
while IFS= read -r f; do
  [ -f "$f" ] || continue
  info=$(@ffprobe@ -v error -show_entries format_tags=album,artist,album_artist -of json "$f" </dev/null)
  album=$(@jq@ -r '.format.tags.album // empty' <<<"$info")
  [ -n "$album" ] || continue
  [ -z "$(@jq@ -r '.format.tags.album_artist // empty' <<<"$info")" ] || continue
  tracks[$album]+="$f"$'\n'
done <"$list"

for album in "${!tracks[@]}"; do
  mapfile -t files < <(printf '%s' "${tracks[$album]}")
  [ "${#files[@]}" -ge 2 ] || continue
  # one JSON array of artists per track, then the artists common to all tracks
  common=$(for f in "${files[@]}"; do
    @ffprobe@ -v error -show_entries format_tags=artist -of json "$f" </dev/null | @jq@ -c '(.format.tags.artist // "") | split(", ")'
  done | @jq@ -rs 'if (map(join(",")) | unique | length) < 2 then empty
    else (reduce .[1:][] as $a (.[0]; map(select(. as $x | $a | index($x)))) | join(", ")) as $c
    | if $c == "" then "Various Artists" else $c end end')
  [ -n "$common" ] || continue
  for f in "${files[@]}"; do
    tmp="$f.tagtmp.m4a"
    if @ffmpeg@ -nostdin -v error -y -i "$f" -map 0:a -map "0:v?" -c copy -movflags +faststart \
      -metadata "album_artist=$common" "$tmp" && [ -s "$tmp" ]; then
      mv "$tmp" "$f"
    else
      rm -f "$tmp"
      echo "album-artist: failed on $f" >&2
    fi
  done
  echo "album-artist: $album -> $common (${#files[@]} tracks)"
done
