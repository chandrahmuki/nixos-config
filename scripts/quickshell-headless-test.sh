#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_root="$(mktemp -d /tmp/mh.XXXXXX)"
runtime_dir="$test_root/r"
config_home="$test_root/c"
data_home="$test_root/data"
cache_home="$test_root/cache"
mock_bin="$test_root/bin"
mkdir -p "$runtime_dir" "$config_home/quickshell" "$data_home" "$cache_home" "$mock_bin"
chmod 700 "$runtime_dir"
cp -a "$repo_root/quickshell" "$config_home/quickshell/muggy"
# Sway has no Hyprland monitor objects. Remove only those monitor-routing
# predicates in the temporary copy so the real panel contents and layer-shell
# surfaces can be captured on the single virtual output.
sed -i '/&& Hyprland\.monitorFor(modelData) === Hyprland\.focusedMonitor/d' \
  "$config_home/quickshell/muggy/windows/ThemeManagerWindow.qml" \
  "$config_home/quickshell/muggy/windows/LauncherWindow.qml"
ln -sfn "$repo_root/wallpapers/nixos_neon_souterrain.png" \
  "$config_home/quickshell/muggy/assets/wallpapers/muggy.png"
ln -sfn "$repo_root/wallpapers/gnome_00_2560x1440.png" \
  "$config_home/quickshell/muggy/assets/wallpapers/gnome-lines.png"
ln -sfn "$repo_root/wallpapers/wallpaperGnome.png" \
  "$config_home/quickshell/muggy/assets/wallpapers/gnome-gradient.png"
sway_store="${SWAY_STORE:-$(XDG_CACHE_HOME=/tmp/codex-nix-cache nix build nixpkgs#sway --no-link --print-out-paths | tail -1)}"
sway_bin="$sway_store/bin/sway"
[[ -x "$sway_bin" ]]

cat > "$mock_bin/muggy-theme" <<'MOCK'
#!/usr/bin/env bash
set -eu
case "${1:-}" in
  current) printf '%s\n' everforest ;;
  apply) printf '%s\n' '{"colors":{}}' ;;
  preview-scheme) printf '%s\n' '#8bc9eb' ;;
  *) exit 0 ;;
esac
MOCK
chmod +x "$mock_bin/muggy-theme"

cat > "$test_root/sway.conf" <<'SWAY'
output * resolution 1920x1080
default_border none
focus_follows_mouse no
xwayland disable
SWAY

if [[ "${1:-}" != "--inner" ]]; then
  exec dbus-run-session -- "$0" --inner "$test_root"
fi

sway_pid=""
qs_pid=""
cleanup() {
  [[ -z "$qs_pid" ]] || kill "$qs_pid" 2>/dev/null || true
  [[ -z "$sway_pid" ]] || kill "$sway_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

export HOME="$test_root/home"
mkdir -p "$HOME"
export XDG_RUNTIME_DIR="$runtime_dir"
export XDG_CONFIG_HOME="$config_home"
export XDG_DATA_HOME="$data_home"
export XDG_CACHE_HOME="$cache_home"
export XDG_STATE_HOME="$test_root/state"
export XDG_DATA_DIRS="/run/current-system/sw/share:/etc/profiles/per-user/david/share"
export PATH="$mock_bin:$sway_store/bin:/etc/profiles/per-user/david/bin:/run/current-system/sw/bin:/run/wrappers/bin:$PATH"
export WLR_BACKENDS=headless
export WLR_RENDERER=pixman
export WLR_LIBINPUT_NO_DEVICES=1
unset WAYLAND_DISPLAY WAYLAND_SOCKET DISPLAY HYPRLAND_INSTANCE_SIGNATURE HYPRLAND_CMD XDG_CURRENT_DESKTOP

"$sway_bin" -d -c "$test_root/sway.conf" >"$test_root/sway.log" 2>&1 &
sway_pid=$!
for _ in $(seq 1 100); do
  sway_socket="$(find "$runtime_dir" -maxdepth 1 -type s -name 'sway-ipc.*.sock' -print -quit 2>/dev/null || true)"
  wayland_name="$(sed -n "s/.*Running compositor on wayland display '\([^']*\)'.*/\1/p" "$test_root/sway.log" | tail -1)"
  [[ -n "$wayland_name" && -n "$sway_socket" ]] && break
  sleep 0.2
done
[[ -n "${wayland_name:-}" && -n "${sway_socket:-}" ]]
export WAYLAND_DISPLAY="$wayland_name"
export SWAYSOCK="$sway_socket"
swaymsg -t get_outputs >/dev/null

qs --config muggy --no-duplicate >"$test_root/quickshell.log" 2>&1 &
qs_pid=$!
for _ in $(seq 1 100); do
  if qs --config muggy ipc show >/dev/null 2>&1; then break; fi
  sleep 0.2
done
qs --config muggy ipc show >"$test_root/ipc-targets.txt"
theme_to_apply="${MUGGY_HEADLESS_THEME:-flexoki-light}"

capture() {
  grim "$test_root/$1.png"
  printf 'CAPTURE %s\n' "$test_root/$1.png"
}

qs --config muggy ipc call shell toggleThemeManager
sleep 1
capture theme-manager-open
# Sway headless has no virtual-keyboard manager, so exercise the shell's
# apply handler directly after visually checking the selector surface.
qs --config muggy ipc call shell applyTheme "$theme_to_apply"
sleep 1
capture wallpaper-after-apply
qs --config muggy ipc call shell toggleThemeManager
sleep 0.5
capture theme-manager-after-apply
qs --config muggy ipc call shell toggleThemeManager
sleep 0.3
capture theme-manager-closed
qs --config muggy ipc call shell toggleLauncher
sleep 0.5
capture launcher-open
qs --config muggy ipc call shell toggleLauncher
sleep 0.3
capture launcher-closed

printf 'TEST_ROOT %s\n' "$test_root"
printf 'QUICKSHELL_PID %s\n' "$qs_pid"
printf 'SWAY_PID %s\n' "$sway_pid"
printf 'LOGS %s %s\n' "$test_root/sway.log" "$test_root/quickshell.log"
