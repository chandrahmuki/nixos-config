# Judge for visual interfaces

Checked on 2026-10-15 while fixing the clock panel. Anything not listed here is untested.

## Setup

- `scripts/vm-test.sh start` boots the real config headless (first start builds, can exceed 10 min: run it in the background and poll `exec 'echo ready'`). Screen is 1280x800.
- `start` returning means Hyprland answers, not that the shell is ready: right after it the screen is black, then the splash. Take a shot and wait until the pill is drawn before any test, or the test measures the boot.
- `shot NAME` prints a PNG path under `/tmp/muggy-vm/`. Open it with the image reader and check each expected element, order and spacing against the criterion.
- Always `stop` afterwards (it removes `/tmp/muggy-vm`).

## Traps found

- **The VM does not hot-reload Quickshell.** It mounts the host checkout over 9p (read-only) and file change events do not cross it. After editing QML, run `vm-test.sh reload`, otherwise the screenshot shows the old code. It prints the old and new PID and fails if "Configuration Loaded" is missing or the PID did not change. The VM sees the edit immediately (`exec 'grep ... file'`); only the shell is stale. Checked both ways: with the file at `blockWidth: 7` and no reload, the shot still showed the fixed layout; after `reload` the overflow came back.
- **The user's live Quickshell did not reload either** after an edit made from the checkout (one "Configuration Loaded" since its start, edit 45 min later). Check with `qs list --all` (launch time) and `qs log -c muggy`. Restarting it is `restart-quickshell`, only with the user's go-ahead.
- `pgrep -x quickshell` matches nothing; use `pgrep -af "bin/quickshell"`.
- `hyprctl dispatch ...` in the VM runs Lua (`hl.dispatch(...)`), so `hypr dispatch movecursor X Y` fails.
- Hover: `vm-test.sh mouse move X Y` moves the pointer without a click. Move away first (for example `600 300`), then onto the target, and wait about 1.5 s for the open timer before the shot. Moving away again closes the panel.

## Layout bugs

- A `Row` or `Layout` child with its own width (for example a gauge of N blocks) sets the minimum size of the layout around it and can widen it past its allotment. Add up the fixed widths against the container width before blaming the text.
- Compare the right edge of the clipped text with the right edge of a neighbouring element (header status text) in the screenshot: same x means it fits.
