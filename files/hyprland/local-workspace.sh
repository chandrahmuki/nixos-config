action="$1"

local_offset() {
  focused_output="$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')"
  case "$focused_output" in
    DP-2) echo 0 ;;
    HDMI-A-1) echo 5 ;;
    *)
      echo "Unsupported focused monitor: $focused_output" >&2
      exit 1
      ;;
  esac
}

case "$action" in
  focus|move)
    slot="$2"
    case "$slot" in
      1|2|3|4|5) ;;
      *)
        echo "Workspace slot must be between 1 and 5." >&2
        exit 1
        ;;
    esac

    target=$(( $(local_offset) + slot ))
    if [ "$action" = focus ]; then
      hyprctl dispatch "hl.dsp.focus({ workspace = $target })"
    else
      hyprctl dispatch "hl.dsp.window.move({ workspace = $target })"
    fi
    ;;
  cycle)
    direction="$2"
    case "$direction" in
      next|previous) ;;
      *)
        echo "Cycle direction must be next or previous." >&2
        exit 1
        ;;
    esac

    offset="$(local_offset)"
    current="$(hyprctl monitors -j | jq -r '.[] | select(.focused).activeWorkspace.id')"
    slot=$((current - offset))

    # Workspace slots are local to each monitor, even though their
    # Hyprland IDs are global (1–5 on DP-2, 6–10 on HDMI-A-1).
    case "$slot" in
      1|2|3|4|5) ;;
      *)
        echo "Focused workspace $current is outside this monitor's local range." >&2
        exit 1
        ;;
    esac

    if [ "$direction" = next ]; then
      slot=$((slot % 5 + 1))
    else
      slot=$(((slot + 3) % 5 + 1))
    fi

    hyprctl dispatch "hl.dsp.focus({ workspace = $((offset + slot)) })"
    ;;
  migrate-legacy-right)
    # One-time migration: preserve the windows that were created on
    # the right display before it received its own local 1–5 range.
    for mapping in "3 8" "4 9" "5 10"; do
      read -r source target <<< "$mapping"
      hyprctl clients -j | jq -r --argjson workspace "$source" \
        '.[] | select(.workspace.id == $workspace) | .address' \
        | while IFS= read -r address; do
          [ -n "$address" ] || continue
          hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })"
          hyprctl dispatch "hl.dsp.window.move({ workspace = $target })"
        done
    done
    hyprctl dispatch 'hl.dsp.focus({ workspace = 8 })'
    ;;
  *)
    echo "Usage: local-workspace {focus|move} {1..5}" >&2
    echo "       local-workspace cycle {next|previous}" >&2
    echo "       local-workspace migrate-legacy-right" >&2
    exit 1
    ;;
esac
