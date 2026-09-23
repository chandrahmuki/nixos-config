#!/usr/bin/env bash
# Self-test for the muggy theme system (Quickshell + Matugen + Kitty/GTK).
#
# Run this after touching anything theme-related (aspects/hyprland.nix,
# quickshell/shell.qml, quickshell/windows/*.qml, quickshell/assets/wallpapers/*)
# *before* asking the user to click through it by hand. It exercises every
# theme end to end and checks the parts a human would otherwise have to
# eyeball: backend script success, generated colour files, live Kitty push,
# Quickshell's own QML load, and the exact hyprpaper-layer-race class of bug
# that has bitten this setup more than once.
#
# Usage: scripts/theme-selftest.sh [--skip-quickshell-restart]
#
# Exit code is nonzero if anything failed. Prints one PASS/FAIL line per
# check plus a final summary; on failure the offending command's output is
# shown inline so there's no need to re-run anything by hand to see why.

set -uo pipefail
cd "$(dirname "$0")/.."

REPO_ROOT="$PWD"
THEMES=(muggy gnome-lines gnome-gradient)
FAIL=0
SKIP_RESTART=false
[[ "${1:-}" == "--skip-quickshell-restart" ]] && SKIP_RESTART=true

pass() { printf '  \033[32mPASS\033[0m %s\n' "$1"; }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=1; }
section() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

# --- 1. Wallpaper assets present for every theme -----------------------
section "Wallpaper assets"
for id in "${THEMES[@]}"; do
  wallpaper="$REPO_ROOT/quickshell/assets/wallpapers/$id.png"
  if [[ -s "$wallpaper" ]]; then
    pass "$id"
  else
    fail "$id — missing or empty: $wallpaper"
  fi
done

# --- 2. Backend script: apply every theme, check colours actually land --
section "muggy-theme apply <id> (backend + colour files)"
if ! command -v muggy-theme >/dev/null 2>&1; then
  fail "muggy-theme not on PATH — is it installed? (which muggy-theme)"
else
  ORIGINAL_THEME="$(muggy-theme current 2>/dev/null || echo muggy)"
  COLOR_CHECK="$REPO_ROOT/scripts/theme-color-check.py"
  for id in "${THEMES[@]}"; do
    palette_json="$(mktemp)"
    err="$(muggy-theme apply "$id" 2>&1 1>"$palette_json")"
    code=$?
    if [[ $code -ne 0 ]]; then
      fail "$id — apply exited $code: $err"
      rm -f "$palette_json"
      continue
    fi
    current="$(muggy-theme current)"
    if [[ "$current" != "$id" ]]; then
      fail "$id — state file says '$current' after apply"
      rm -f "$palette_json"
      continue
    fi
    kitty_bg="$(grep -m1 '^background' "$HOME/.cache/muggy/kitty-theme.conf" 2>/dev/null || true)"
    gtk_bg="$(grep -m1 'window_bg_color' "$HOME/.cache/muggy/gtk-matugen.css" 2>/dev/null || true)"
    if [[ -z "$kitty_bg" || -z "$gtk_bg" ]]; then
      fail "$id — colour files missing expected keys (kitty: '$kitty_bg', gtk: '$gtk_bg')"
      rm -f "$palette_json"
      continue
    fi
    # Does the generated palette actually read as this theme, or did the
    # wallpaper crop / --prefer choice hand it a wrong-hue accent instead?
    if [[ -x "$COLOR_CHECK" || -f "$COLOR_CHECK" ]]; then
      color_msg="$(python3 "$COLOR_CHECK" "$id" "$palette_json" 2>&1)"
      color_code=$?
      if [[ $color_code -ne 0 ]]; then
        fail "$id — $color_msg"
        rm -f "$palette_json"
        continue
      fi
    else
      color_msg=""
    fi
    rm -f "$palette_json"
    pass "$id — kitty $kitty_bg / gtk $gtk_bg${color_msg:+ / $color_msg}"
  done
  # Live-push check: only meaningful if a Kitty window is actually open.
  shopt -s nullglob
  sockets=("$XDG_RUNTIME_DIR"/kitty-*)
  shopt -u nullglob
  if [[ ${#sockets[@]} -eq 0 ]]; then
    printf '  \033[33mSKIP\033[0m no live Kitty socket found — can'"'"'t verify the live push\n'
  else
    for sock in "${sockets[@]}"; do
      if kitty @ --to "unix:$sock" set-colors --all --configured "$HOME/.cache/muggy/kitty-theme.conf" >/dev/null 2>&1; then
        pass "live push to $(basename "$sock")"
      else
        fail "live push to $(basename "$sock") failed"
      fi
    done
  fi
  muggy-theme apply "$ORIGINAL_THEME" >/dev/null 2>&1 || true
fi

# --- 3. hyprpaper must never be declared or running ---------------------
section "hyprpaper stays dead (regression guard)"
if systemctl --user list-unit-files 2>/dev/null | grep -q '^hyprpaper\.service'; then
  fail "hyprpaper.service is still a known unit — systemctl --user list-unit-files | grep hyprpaper"
else
  pass "no hyprpaper.service unit registered"
fi
if pgrep -x hyprpaper >/dev/null 2>&1; then
  fail "hyprpaper process is running (pid $(pgrep -x hyprpaper | tr '\n' ' '))"
else
  pass "no hyprpaper process running"
fi
bg_layers="$(hyprctl layers 2>/dev/null | grep -c 'namespace: muggy-background')"
stray_layers="$(hyprctl layers 2>/dev/null | grep -Ec 'namespace: (hyprpaper|hyprland-background)')"
if [[ "$stray_layers" -gt 0 ]]; then
  fail "a competing background-layer client is present (hyprctl layers | grep namespace)"
elif [[ "$bg_layers" -gt 0 ]]; then
  pass "muggy-background is the only background-layer client ($bg_layers surface(s))"
else
  printf '  \033[33mSKIP\033[0m muggy-background layer not found — is Quickshell running?\n'
fi

# --- 4. QML loads clean --------------------------------------------------
section "Quickshell QML"
QMLLINT="$(find /nix/store -maxdepth 4 -type f -name qmllint 2>/dev/null | head -1)"
if [[ -n "$QMLLINT" && -n "$(find /nix/store -maxdepth 5 -type d -path '*qtdeclarative-*/lib/qt-6/qml' 2>/dev/null | head -1)" ]]; then
  # Not a fixed offset from qmllint's own path — locate the actual qml/
  # import trees by name instead of guessing dirname depth.
  QT_IMPORT="$(find /nix/store -maxdepth 5 -type d -path '*qtdeclarative-*/lib/qt-6/qml' 2>/dev/null | head -1)"
  QS_IMPORT="$(find /nix/store -maxdepth 5 -type d -path '*quickshell-*/lib/qt-6/qml' 2>/dev/null | head -1)"
  lint_fail=0
  for f in "$REPO_ROOT"/quickshell/*.qml "$REPO_ROOT"/quickshell/windows/*.qml; do
    [[ -f "$f" ]] || continue
    # Only [import]-tagged warnings and hard "Error:" lines are treated as
    # real: this codebase leans on dynamic attached properties (PathView-
    # style custom PathAttributes, animation-only properties like
    # holdProgress) and skips `pragma ComponentBehavior: Bound` throughout,
    # both of which qmllint flags constantly as [missing-property] /
    # [unqualified] / [signal-handler-parameters] noise unrelated to
    # whether the file actually works.
    errs="$("$QMLLINT" -I "$QT_IMPORT" -I "$QS_IMPORT" "$f" 2>&1 | grep -E '^Error|\[import\]')"
    if [[ -n "$errs" ]]; then
      fail "qmllint $(basename "$f"):"
      echo "$errs" | sed 's/^/         /'
      lint_fail=1
    fi
  done
  [[ $lint_fail -eq 0 ]] && pass "qmllint clean on all quickshell/*.qml"
else
  printf '  \033[33mSKIP\033[0m qmllint not found under /nix/store\n'
fi

if $SKIP_RESTART; then
  printf '  \033[33mSKIP\033[0m quickshell restart (--skip-quickshell-restart)\n'
elif command -v restart-quickshell >/dev/null 2>&1; then
  restart-quickshell >/dev/null 2>&1
  sleep 1.5
  log="$(ls -t "$XDG_RUNTIME_DIR"/quickshell/by-id/*/log.qslog 2>/dev/null | head -1)"
  if [[ -z "$log" ]]; then
    fail "no quickshell log found after restart"
  else
    errs="$(grep -aiE 'warn|error' "$log" | grep -av '^module\|Scanning qml file')"
    if [[ -n "$errs" ]]; then
      fail "quickshell log has warnings/errors:"
      echo "$errs" | sed 's/^/         /'
    else
      pass "quickshell reloaded clean ($log)"
    fi
  fi
else
  printf '  \033[33mSKIP\033[0m restart-quickshell not on PATH\n'
fi

# --- 5. Full apply through QML (IPC), not just the shell script ---------
section "End-to-end apply via Quickshell IPC"
if command -v qs >/dev/null 2>&1 && ! $SKIP_RESTART; then
  before="$(muggy-theme current)"
  target="gnome-lines"; [[ "$before" == "gnome-lines" ]] && target="gnome-gradient"
  if timeout 5 qs -c muggy ipc call shell applyTheme "$target" >/dev/null 2>&1; then
    sleep 1
    after="$(muggy-theme current)"
    if [[ "$after" == "$target" ]]; then
      pass "IPC applyTheme $target -> state file updated"
    else
      fail "IPC applyTheme $target -> state file still says '$after'"
    fi
  else
    fail "qs ipc call shell applyTheme $target failed or timed out"
  fi
  qs -c muggy ipc call shell applyTheme "$before" >/dev/null 2>&1 || true
else
  printf '  \033[33mSKIP\033[0m qs not on PATH or restart was skipped\n'
fi

# --- Summary --------------------------------------------------------------
section "Summary"
if [[ $FAIL -eq 0 ]]; then
  printf '\033[32mAll checks passed.\033[0m\n'
else
  printf '\033[31mSome checks failed — see FAIL lines above.\033[0m\n'
fi
exit $FAIL
