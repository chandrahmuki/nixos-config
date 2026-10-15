#!/usr/bin/env bash
# player [folder|file|playlist.m3u]   play in the background (control it from the pill)
# player -f [target]                  play in this terminal with the retro UI
# player save | stop | toggle | next | prev   talk to the running player
# player theme [name]                 list the themes, or pick the one for the next launches
# In the UI, R swaps the music for the radio stations (stations: ~/.config/player/radios.json, see files/player/radios.md)
# Default target: ~/Music. A folder is played recursively.
socket="${PLAYER_SOCKET:-/tmp/mpv-player.sock}"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/player"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/player"

# Names of the built-in themes and of yours (~/.config/player/themes/*.json).
theme_names() {
  local dir file
  for dir in @themes@ "$config_dir/themes"; do
    for file in "$dir"/*.json; do
      [ -e "$file" ] && basename "$file" .json
    done
  done | sort -u
}

send() {
  printf '{"command": %s}\n' "$1" | @socat@ - "$socket" >/dev/null
}

running() {
  [ -S "$socket" ] && send '["get_version"]' 2>/dev/null
}

case "${1:-}" in
  theme)
    if [ "${2:-}" = new ]; then
      # player theme new NAME [BASE]: a starting point extending BASE (default pastel),
      # with its colors copied so you only edit the hex values.
      name="${3:-}"
      base="${4:-pastel}"
      if [ -z "$name" ] || ! printf '%s' "$name" | grep -qE '^[a-z0-9_-]+$'; then
        echo "usage: player theme new NAME [BASE]  (NAME: letters, digits, - and _)" >&2
        exit 1
      fi
      if ! theme_names | grep -qx -- "$base"; then
        echo "player: no theme called $base to start from (try: player theme)" >&2
        exit 1
      fi
      file="$config_dir/themes/$name.json"
      if [ -e "$file" ]; then
        echo "player: $file already exists" >&2
        exit 1
      fi
      for dir in "$config_dir/themes" @themes@; do
        [ -f "$dir/$base.json" ] && { source_file="$dir/$base.json"; break; }
      done
      mkdir -p "$config_dir/themes"
      @jq@ --arg base "$base" --arg label "$name" '{extends: $base, label: $label, colors: .colors}' "$source_file" > "$file"
      echo "$file"
      echo "edit the colors, then press t in the player to see it (player theme $name to start with it)"
      exit 0
    fi
    if [ $# -lt 2 ]; then
      current="$(cat "$state_dir/theme" 2>/dev/null || echo pastel)"
      theme_names | while read -r name; do
        if [ "$name" = "$current" ]; then echo "* $name"; else echo "  $name"; fi
      done
      exit 0
    fi
    if ! theme_names | grep -qx -- "$2"; then
      echo "player: no theme called $2 (try: player theme)" >&2
      exit 1
    fi
    mkdir -p "$state_dir"
    echo "$2" > "$state_dir/theme"
    echo "player: theme $2 for the next launches (t / T switch it live)"
    exit 0
    ;;
  save | stop | toggle | next | prev)
    running || { echo "player: nothing is playing" >&2; exit 1; }
    case "$1" in
      save) send '["script-message", "player-make-playlist"]' ;;
      stop) send '["quit"]' ;;
      toggle) send '["cycle", "pause"]' ;;
      next) send '["playlist-next"]' ;;
      prev) send '["playlist-prev"]' ;;
    esac
    exit 0
    ;;
esac

foreground=0
if [ "${1:-}" = "-f" ]; then
  foreground=1
  shift
fi

target="${1:-$HOME/Music}"
[ $# -gt 0 ] && shift

if [ ! -e "$target" ]; then
  echo "player: $target not found" >&2
  exit 1
fi

target="$(realpath "$target")"
if [ -d "$target" ]; then
  PLAYER_DIR="$target"
else
  PLAYER_DIR="$(dirname "$target")"
fi
export PLAYER_DIR

# One player at a time: replace the running one (never pkill, mpvpaper is mpv too).
running && send '["quit"]'

args=(
  --no-video --audio-display=no --vo=null --force-window=no
  --directory-mode=recursive --directory-filter-types=audio --loop-playlist=inf
  --input-ipc-server="$socket" --script=@script@
)

if [ "$foreground" = 1 ]; then
  # The UI draws a CAVA spectrum: keep its latest frame in a file. cava stops by
  # itself (SIGPIPE) once the awk that reads it is killed.
  PLAYER_VIZ="${XDG_RUNTIME_DIR:-/tmp}/player-cava.$$"
  mkdir -p "$state_dir"
  export PLAYER_VIZ PLAYER_STATE_DIR="$state_dir" PLAYER_THEMES=@themes@ PLAYER_USER_THEMES="$config_dir/themes" \
    PLAYER_RADIOS=@radios@ PLAYER_USER_RADIOS="$config_dir/radios.json"
  printf '%s\n' '[general]' 'bars = 22' 'framerate = 20' 'autosens = 1' \
    '[input]' 'method = pulse' 'source = auto' \
    '[output]' 'method = raw' 'raw_target = /dev/stdout' 'data_format = ascii' \
    'ascii_max_range = 48' 'bar_delimiter = 59' 'frame_delimiter = 10' |
    @cava@ -p /dev/stdin 2>/dev/null |
    @awk@ -v out="$PLAYER_VIZ" '{ printf "%s\n", $0 > out; close(out) }' &
  viz_pid=$!
  trap 'kill "$viz_pid" 2>/dev/null; rm -f "$PLAYER_VIZ"' EXIT
  trap 'exit 130' INT TERM HUP
  @mpv@ "${args[@]}" \
    --really-quiet --msg-level=all=no --term-status-msg= --osd-level=0 --no-osc \
    "$@" -- "$target"
  exit $?
fi

export PLAYER_BG=1
setsid @mpv@ "${args[@]}" --no-terminal --idle=no "$@" -- "$target" >/dev/null 2>&1 < /dev/null &
echo "player: playing $target (player stop / save / toggle / next / prev)"
