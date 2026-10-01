set -euo pipefail

state_root="${XDG_STATE_HOME:-$HOME/.local/state}/muggy"
state_file="$state_root/theme"

current_theme() {
  if [ -r "$state_file" ]; then cat "$state_file"; else printf '%s\n' muggy; fi
}

# Shared by apply_theme and preview_scheme so the wallpaper, mode,
# and --prefer choice per theme lives in exactly one place.
resolve_background() {
  theme="$1"
  # Matugen picks its palette from whichever colour in the image
  # best matches "prefer" — not from the curated Quickshell swatch.
  # "saturation" (the default) picks the most vivid hue, which for
  # most photos is the one that actually reads as that theme's
  # colour; a few images needed a different rule to land on the
  # blue/green the theme is named for instead of an incidental
  # sky or parchment tone.
  prefer="saturation"
  theme_mode="dark"
  theme_accent=""
  case "$theme" in
    muggy) background="@wallpaper@" ;;
    gnome-lines) background="@gnomeLinesWallpaper@"; prefer="lightness" ;;
    gnome-gradient) background="@gnomeGradientWallpaper@"; prefer="darkness" ;;
    catppuccin) background="@muggynixWallpaperDir@/quattro-catppuccin.jpg"; theme_accent="#89b4fa" ;;
    catppuccin-latte) background="@muggynixWallpaperDir@/quattro-catppuccin-latte.jpg"; theme_mode="light"; theme_accent="#1e66f5" ;;
    ethereal) background="@muggynixWallpaperDir@/quattro-ethereal.jpg"; theme_accent="#7d82d9" ;;
    everforest) background="@muggynixWallpaperDir@/quattro-everforest.jpg"; theme_accent="#7fbbb3" ;;
    flexoki-light) background="@muggynixWallpaperDir@/muggynix-flexoki-light.jpg"; theme_mode="light"; theme_accent="#205EA6" ;;
    gruvbox) background="@muggynixWallpaperDir@/quattro-gruvbox.jpg"; theme_accent="#7daea3" ;;
    hackerman) background="@muggynixWallpaperDir@/quattro-hackerman.jpg"; theme_accent="#82FB9C" ;;
    kanagawa) background="@muggynixWallpaperDir@/quattro-kanagawa.jpg"; theme_accent="#dcd7ba" ;;
    last-horizon) background="@muggynixWallpaperDir@/quattro-last-horizon.jpg"; theme_accent="#b59790" ;;
    lumon) background="@muggynixWallpaperDir@/quattro-lumon.jpg"; theme_accent="#8bc9eb" ;;
    lupine) background="@muggynixWallpaperDir@/muggynix-lupine.jpg"; theme_mode="light"; theme_accent="#3264eb" ;;
    matte-black) background="@muggynixWallpaperDir@/quattro-matte-black.jpg"; theme_accent="#e68e0d" ;;
    miasma) background="@muggynixWallpaperDir@/quattro-miasma.jpg"; theme_accent="#78824b" ;;
    nord) background="@muggynixWallpaperDir@/quattro-nord.jpg"; theme_accent="#81a1c1" ;;
    osaka-jade) background="@muggynixWallpaperDir@/quattro-osaka-jade.jpg"; theme_accent="#509475" ;;
    retro-82) background="@muggynixWallpaperDir@/quattro-retro-82.jpg"; theme_accent="#faa968" ;;
    ristretto) background="@muggynixWallpaperDir@/quattro-ristretto.jpg"; theme_accent="#f38d70" ;;
    rose-pine) background="@muggynixWallpaperDir@/muggynix-rose-pine.jpg"; theme_mode="light"; theme_accent="#56949f" ;;
    solitude) background="@muggynixWallpaperDir@/quattro-solitude.jpg"; theme_accent="#798186" ;;
    tokyo-night) background="@muggynixWallpaperDir@/quattro-tokyo-night.jpg"; theme_accent="#7aa2f7" ;;
    vantablack) background="@muggynixWallpaperDir@/quattro-vantablack.jpg"; theme_accent="#8d8d8d" ;;
    white) background="@muggynixWallpaperDir@/quattro-white.jpg"; theme_mode="light"; theme_accent="#6e6e6e" ;;
    *) echo "Unknown Muggy theme: $theme" >&2; exit 2 ;;
  esac
}

# Quattro's accent is curated in colors.toml. Keep that exact accent
# while Matugen derives the rest of the palette from its wallpaper.
apply_theme_accent() {
  if [ -z "$theme_accent" ]; then
    cat
  elif [ "$theme" = solitude ]; then
    # Solitude's official Quattro colors.toml is deliberately
    # monochrome. Matugen samples the wallpaper's warm highlights,
    # which otherwise gives GTK an olive background and pink errors.
    jq --arg accent "$theme_accent" '
      .colors.primary.dark.color = $accent
      | .colors.primary.default.color = $accent
      | .colors.primary.light.color = $accent
      | .colors.primary_container.dark.color = "#343d41"
      | .colors.on_primary.dark.color = "#101315"
      | .colors.on_primary_container.dark.color = "#cacccc"
      | .colors.background.dark.color = "#101315"
      | .colors.on_background.dark.color = "#cacccc"
      | .colors.surface.dark.color = "#101315"
      | .colors.on_surface.dark.color = "#cacccc"
      | .colors.surface_container.dark.color = "#101315"
      | .colors.surface_container_low.dark.color = "#0c0e10"
      | .colors.surface_container_high.dark.color = "#343d41"
      | .colors.error.dark.color = "#de6145"
      | .colors.success.dark.color = "#9fa5a9"
      | .colors.warning.dark.color = "#d9dbdc"
      | .colors.secondary.dark.color = "#707070"
      | .colors.tertiary.dark.color = "#9fa5a9"
      | .colors.primary_fixed.dark.color = "#9a9a9a"
      | .colors.primary_fixed_dim.dark.color = "#5d6367"
      | .colors.secondary_fixed.dark.color = "#707070"
      | .colors.secondary_fixed_dim.dark.color = "#4b4e55"
      | .colors.tertiary_fixed.dark.color = "#9fa5a9"
      | .colors.tertiary_fixed_dim.dark.color = "#798186"
      | .colors.outline.dark.color = "#4b4e55"
      | .colors.outline_variant.dark.color = "#4b4e55"
    '
  else
    jq --arg accent "$theme_accent" '
      .colors.primary.dark.color = $accent
      | .colors.primary.default.color = $accent
      | .colors.primary.light.color = $accent
    '
  fi
}

# Fast, side-effect-free: resolves the theme's wallpaper and runs
# Matugen with a caller-chosen --type, printing just the primary
# colour. Used by the theme deck's live scheme-algorithm swatches,
# which call this once per candidate algorithm on every carousel
# selection — no state write, no Kitty/GTK push, no border change.
preview_scheme() {
  theme="$1"
  scheme="${2:-scheme-vibrant}"
  resolve_background "$theme"
  matugen image "$background" --mode "$theme_mode" --prefer "$prefer" --type "$scheme" --json hex \
    | apply_theme_accent \
    | jq -r '.colors.primary.dark.color'
}

apply_theme() {
  theme="$1"
  scheme="${2:-scheme-vibrant}"
  resolve_background "$theme"

  mkdir -p "$state_root"
  printf '%s\n' "$theme" > "$state_file.tmp"
  mv "$state_file.tmp" "$state_file"
  # Wallpaper display itself is Quickshell's own BackgroundWindow now
  # (reacting to activeThemeId directly) — hyprpaper is gone, so
  # there is nothing to push the image to here.

  # Matugen is deliberately non-interactive here: a UI action must
  # never wait for a terminal prompt when the image has several
  # suitable source colours.
  # $scheme (default scheme-vibrant, picked in the theme deck)
  # keeps the same hue matugen already chose via $prefer but
  # controls how far it pushes saturation/contrast from there —
  # the tonal-spot Matugen default tended to read as washed-out.
  palette="$(matugen image "$background" --mode "$theme_mode" --prefer "$prefer" --type "$scheme" --json hex | apply_theme_accent)"
  primary="$(printf '%s' "$palette" | jq -r '.colors.primary.dark.color | ltrimstr("#")')"
  outline="$(printf '%s' "$palette" | jq -r '.colors.outline_variant.dark.color | ltrimstr("#")')"

  # Kitty imports this mutable Matugen fragment. After an atomic
  # update, remote control applies it to all live Kitty windows.
  cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/muggy"
  mkdir -p "$cache_root"
  kitty_theme="$cache_root/kitty-theme.conf"
  kitty_theme_tmp="$(mktemp "$cache_root/kitty-theme.XXXXXX")"
  printf '%s' "$palette" | jq -r '
    def c($name): .colors[$name].dark.color;
    "background \(c("background"))",
    "foreground \(c("on_surface"))",
    "cursor \(c("primary"))",
    "selection_background \(c("primary_container"))",
    "selection_foreground \(c("on_primary_container"))",
    # Terminal TUIs commonly paint their canvas with ANSI black.
    # Keep it aligned with the actual Matugen background instead of
    # surface_container_highest or primary_container, both of which
    # carry enough hue from the source colour to read green.
    "color0 \(c("background"))",
    "color1 \(c("error"))",
    "color2 \(c("primary"))",
    "color3 \(c("secondary"))",
    "color4 \(c("tertiary"))",
    "color5 \(c("primary_fixed"))",
    "color6 \(c("secondary_fixed"))",
    "color7 \(c("on_surface"))",
    "color8 \(c("outline"))",
    "color9 \(c("error"))",
    "color10 \(c("primary_fixed"))",
    "color11 \(c("secondary_fixed"))",
    "color12 \(c("tertiary_fixed"))",
    "color13 \(c("primary_fixed"))",
    "color14 \(c("secondary"))",
    "color15 \(c("on_background"))"
  ' > "$kitty_theme_tmp"
  mv "$kitty_theme_tmp" "$kitty_theme"
  # Kitty suffixes a bare listen_on path with its own PID (our
  # config now spells that out via {kitty_pid}), so there is no
  # single fixed socket to target: push to every live window.
  for kitty_socket in "/run/user/$(id -u)"/kitty-*; do
    [ -S "$kitty_socket" ] || continue
    kitty @ --to "unix:$kitty_socket" set-colors --all --configured "$kitty_theme" >/dev/null 2>&1 || true
  done

  # GTK3/GTK4 both import this small final CSS file after their
  # declarative Stylix base. This gives Matugen precedence without
  # making Nix-managed files mutable.
  gtk_css_tmp="$(mktemp "$cache_root/gtk-matugen.css.XXXXXX")"
  printf '%s' "$palette" | jq -r '
    def c($name): .colors[$name].dark.color;
    "@define-color accent_color \(c("primary"));",
    "@define-color accent_bg_color \(c("primary"));",
    "@define-color accent_fg_color \(c("on_primary"));",
    "@define-color destructive_color \(c("error"));",
    "@define-color destructive_bg_color \(c("error"));",
    "@define-color destructive_fg_color \(c("on_error"));",
    "@define-color success_color \(c("primary_fixed"));",
    "@define-color success_bg_color \(c("primary_fixed"));",
    "@define-color success_fg_color \(c("on_primary_fixed"));",
    "@define-color warning_color \(c("secondary"));",
    "@define-color warning_bg_color \(c("secondary"));",
    "@define-color warning_fg_color \(c("on_secondary"));",
    "@define-color error_color \(c("error"));",
    "@define-color error_bg_color \(c("error"));",
    "@define-color error_fg_color \(c("on_error"));",
    "@define-color window_bg_color \(c("background"));",
    "@define-color window_fg_color \(c("on_background"));",
    "@define-color view_bg_color \(c("surface"));",
    "@define-color view_fg_color \(c("on_surface"));",
    "@define-color headerbar_bg_color \(c("surface_container"));",
    "@define-color headerbar_fg_color \(c("on_surface"));",
    "@define-color headerbar_backdrop_color @window_bg_color;",
    "@define-color sidebar_bg_color \(c("surface_container_low"));",
    "@define-color sidebar_fg_color \(c("on_surface"));",
    "@define-color sidebar_backdrop_color @window_bg_color;",
    "@define-color card_bg_color \(c("surface_container_high"));",
    "@define-color card_fg_color \(c("on_surface"));",
    "@define-color dialog_bg_color \(c("surface_container"));",
    "@define-color dialog_fg_color \(c("on_surface"));",
    "@define-color popover_bg_color \(c("surface_container_high"));",
    "@define-color popover_fg_color \(c("on_surface"));",
    "@define-color theme_selected_bg_color \(c("primary"));",
    "@define-color theme_selected_fg_color \(c("on_primary"));",
    "@define-color theme_fg_color \(c("on_surface"));",
    "@define-color theme_bg_color \(c("background"));"
  ' > "$gtk_css_tmp"
  mv "$gtk_css_tmp" "$cache_root/gtk-matugen.css"

  # Papirus-folders only ships a fixed palette (see `-l`), not
  # arbitrary hex, so this is a hand-picked nearest match per
  # theme rather than anything derived from $palette. Best-effort:
  # a missing/older Papirus build should never fail the apply.
  case "$theme" in
    muggy) folder_color="cyan" ;;
    gnome-lines|gnome-gradient|rose-pine) folder_color="pink" ;;
    catppuccin|catppuccin-latte|lupine|lumon) folder_color="blue" ;;
    ethereal|last-horizon|tokyo-night) folder_color="indigo" ;;
    everforest|hackerman|miasma) folder_color="green" ;;
    flexoki-light|retro-82) folder_color="orange" ;;
    gruvbox|ristretto) folder_color="brown" ;;
    kanagawa) folder_color="bluegrey" ;;
    matte-black|solitude) folder_color="grey" ;;
    nord) folder_color="nordic" ;;
    osaka-jade) folder_color="teal" ;;
    vantablack) folder_color="black" ;;
    white) folder_color="white" ;;
    *) echo "Unknown Muggy theme folder color: $theme" >&2; exit 2 ;;
  esac
  if [ -n "$folder_color" ]; then
    papirus-folders -C "$folder_color" -t Papirus-Dark -u >/dev/null 2>&1 || true
  fi

  # libadwaita only notices its CSS replacement reliably after a
  # color-scheme transition. Restore the user's dark preference.
  gsettings set org.gnome.desktop.interface color-scheme prefer-light
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark

  # This configuration is Lua-based, so legacy `hyprctl keyword`
  # calls do not work. Apply the generated border colours through
  # Hyprland's Lua evaluator instead. A long-lived Quickshell
  # process can inherit a dead instance signature after Hyprland
  # restarts, so resolve the newest live lock for every apply.
  hypr_signature=""
  newest_hypr_lock=0
  for lock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/hypr/*/hyprland.lock; do
    [ -r "$lock" ] || continue
    hypr_pid="$(sed -n '1p' "$lock" 2>/dev/null || true)"
    lock_mtime="$(stat -c %Y "$lock" 2>/dev/null || printf '0')"
    if [ -n "$hypr_pid" ] && kill -0 "$hypr_pid" 2>/dev/null \
      && [ "$lock_mtime" -ge "$newest_hypr_lock" ]; then
      hypr_dir="${lock%/hyprland.lock}"
      hypr_signature="${hypr_dir##*/}"
      newest_hypr_lock="$lock_mtime"
    fi
  done
  if [ -n "$hypr_signature" ]; then
    HYPRLAND_INSTANCE_SIGNATURE="$hypr_signature" \
      hyprctl eval "hl.config({ general = { col = { active_border = \"rgb($primary)\", inactive_border = \"rgb($outline)\" } }, group = { col = { border_active = \"rgb($primary)\" } } })" >/dev/null \
      || echo "Warning: could not update Hyprland border colours" >&2
  else
    echo "Warning: no live Hyprland signature found; skipped border colours" >&2
  fi

  # Quickshell consumes this one-line JSON through SplitParser.
  # Keep it as the final stdout payload; diagnostics stay on stderr.
  # Quickshell's SplitParser receives line-delimited messages. Keep
  # the palette as one complete JSON line or it will try to parse
  # each pretty-printed fragment independently.
  printf '%s\n' "$palette" | jq -c .
}

case "${1:-current}" in
  current) current_theme ;;
  apply) apply_theme "${2:?Usage: muggy-theme apply <theme> [scheme]}" "${3:-scheme-vibrant}" ;;
  preview-scheme) preview_scheme "${2:?Usage: muggy-theme preview-scheme <theme> <scheme>}" "${3:-scheme-vibrant}" ;;
  *) echo "Usage: muggy-theme {current|apply <theme> [scheme]|preview-scheme <theme> <scheme>}" >&2; exit 2 ;;
esac
