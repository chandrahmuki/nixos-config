# Gives the keyboard back to the active window after an unlock. When the pointer
# left the window while the screen was locked, Hyprland keeps reporting it as the
# active window but its client never gets keyboard focus again (kitty draws a
# hollow cursor); focusing the window explicitly restores it.
address=$(hyprctl activewindow -j | jq -r '.address // empty')
if [ -n "$address" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })"
fi
