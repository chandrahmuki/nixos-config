# Judge for visual interfaces

Checked on 2026-10-15 while fixing the clock panel. Anything not listed here is untested.

## Setup

- `scripts/vm-test.sh start` boots the real config headless (first start builds, can exceed 10 min: run it in the background and poll `exec 'echo ready'`). Screen is 1280x800.
- `shot NAME` prints a PNG path under `/tmp/muggy-vm/`. Open it with the image reader and check each expected element, order and spacing against the criterion.
- Always `stop` afterwards (it removes `/tmp/muggy-vm`).

## Traps found

- **The VM does not hot-reload Quickshell.** It mounts the host checkout over 9p (read-only) and file change events do not cross it. After editing QML, restart the shell inside the VM, otherwise the screenshot shows the old code:
  `vm-test.sh exec 'export XDG_RUNTIME_DIR=/run/user/$(id -u); export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -1); export WAYLAND_DISPLAY=$(ls $XDG_RUNTIME_DIR | grep -E "^wayland-[0-9]+$" | head -1); restart-quickshell'`
  Confirm with `exec 'pgrep -af "bin/quickshell"'` (new PID) and "Configuration Loaded". The VM sees the edit immediately (`exec 'grep ... file'`); only the shell is stale.
- **The user's live Quickshell did not reload either** after an edit made from the checkout (one "Configuration Loaded" since its start, edit 45 min later). Check with `qs list --all` (launch time) and `qs log -c muggy`. Restarting it is `restart-quickshell`, only with the user's go-ahead.
- `pgrep -x quickshell` matches nothing; use `pgrep -af "bin/quickshell"`.
- `hyprctl dispatch ...` in the VM runs Lua (`hl.dispatch(...)`), so `hypr dispatch movecursor X Y` fails.
- `vm-test.sh mouse` only has `click` and `drag`. For a hover without clicking, send an absolute pointer move through QMP (`/tmp/muggy-vm/qmp.sock`, `input-send-event` with `abs` axes scaled to 0..32767), first away from the target, then onto it, and wait about 1.5 s for the open timer before the shot.

## Layout bugs

- A `Row` or `Layout` child with its own width (for example a gauge of N blocks) sets the minimum size of the layout around it and can widen it past its allotment. Add up the fixed widths against the container width before blaming the text.
- Compare the right edge of the clipped text with the right edge of a neighbouring element (header status text) in the screenshot: same x means it fits.
