qs --config muggy kill --any-display || true

# A Hyprland restart can leave the shell that invokes this helper
# with the previous HYPRLAND_INSTANCE_SIGNATURE. Resolve the newest
# live lock instead of reconnecting Quickshell to a dead compositor.
hypr_signature=""
newest_hypr_lock=0
for lock in "$XDG_RUNTIME_DIR"/hypr/*/hyprland.lock; do
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

for _ in $(seq 1 50); do
  if ! qs --config muggy list --json --any-display 2>/dev/null | grep -q '"id"'; then
    if [ -n "$hypr_signature" ]; then
      HYPRLAND_INSTANCE_SIGNATURE="$hypr_signature" \
        qs --daemonize --no-duplicate --config muggy
    else
      qs --daemonize --no-duplicate --config muggy
    fi
    exit 0
  fi
  sleep 0.1
done

echo "Quickshell did not stop within 5 seconds." >&2
exit 1
