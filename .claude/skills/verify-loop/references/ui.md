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

- **Modifier + wheel through QMP is racy.** Sending "Super down", the wheel and "Super up" back to back made the bind miss about 5 times in 8 (the wheel reached Hyprland before it had taken the modifier into account, from two virtual devices). With 0.2 s between the modifier press and the wheel, and again before the release, 8 of 8 passed. A flaky bind in a test is the harness until proven otherwise: measure the failure rate on a control (no scratchpad) before blaming the config.
- Hyprland hides a special workspace (scratchpad) as soon as a tiled window gets the focus, so a scratchpad cannot stay open while focus moves to the workspace below.
- A scratchpad that exits at once in the VM (TinyMugg with an empty `~/Music`) is not a scratchpad bug: `ffmpeg -f lavfi -i "sine=frequency=440:duration=600" ~/Music/t.flac` inside the VM gives it something to play.
- Lua `dispatch` from the host: pass the expression in apostrophes, `vm-test.sh hypr dispatch "'hl.dsp.exec_cmd(\"kitty --class t1\")'"`, otherwise the quotes are lost.

- Terminal UIs are tested in the VM with herdr, never tmux: `hypr dispatch "'hl.dsp.exec_cmd(\"kitty --class vt -o font_size=8 herdr --session vt\")'"`, then `herdr --session vt pane send-keys w1:p1 KEY` and `pane read w1:p1 --source visible` from `exec`. The default font makes the pane narrower than a 48-column UI: use `font_size=8`. `send-text` in a burst drops characters; type a search key by key (`send-keys a l i`). A key sent while the app is not in its input mode acts as a command: open the mode first (`/`).
- The VM runs the Lua/QML scripts of the **built** package (store copy). To try a script edit without rebuilding the VM, copy the installed wrapper and point it at the checkout: `sed "s#--script=/nix/store/[^ ]*player.lua#--script=/home/david/nixos-config/files/player/player.lua#" $(command -v player) > /tmp/player-test`.
- yt-dlp in the VM reads the user's config, which wants the cookies of a browser that does not exist there: pass `--ytdl-raw-options=ignore-config=` to mpv for tests, otherwise every YouTube link fails.
- `qs -c muggy ipc call shell applyTheme ID` needs `export WAYLAND_DISPLAY=wayland-1` from `exec`. To measure the pill colour, sample a pixel of the pill background (`magick shot.png -format "%[hex:p{640,12}]" info:`) once the palette has landed (about 7 s after the apply), and compare it with the profile in `ThemeService.qml`.

## Layout bugs

- A `Row` or `Layout` child with its own width (for example a gauge of N blocks) sets the minimum size of the layout around it and can widen it past its allotment. Add up the fixed widths against the container width before blaming the text.
- Compare the right edge of the clipped text with the right edge of a neighbouring element (header status text) in the screenshot: same x means it fits.
