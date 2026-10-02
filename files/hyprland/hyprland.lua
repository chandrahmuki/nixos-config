hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 2,
    layout = "scrolling",
  },
  decoration = {
    rounding = 8,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    blur = {
      enabled = true,
      size = 10,
      passes = 2,
      ignore_opacity = true,
    },
  },
  scrolling = {
    -- Was silently promoting a plain "maximize" (Super+Space, meant
    -- to leave fullscreen at 1 so the pill stays up) to a true
    -- fullscreen (2) whenever the window was alone in its column —
    -- Hyprland made that call, not the Lua toggle_maximized binding,
    -- so the pill's fullscreen==2 hide check fired for something
    -- that was never meant to hide it. Now Super+F is the only path
    -- to real fullscreen.
    fullscreen_on_one_column = false,
    -- Default is 1 (wraps): scrolling past the last column jumps
    -- straight back to the first, which reads as the same window
    -- looping forever regardless of direction. 0 stops at the
    -- boundary column instead.
    wrap_focus = 0,
  },
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = true,
    mouse_move_focuses_monitor = false,
  },
  input = {
    kb_layout = "us",
    -- AltGr dead keys for the French accent layer of the Preonic keymap.
    kb_variant = "altgr-intl",
    follow_mouse = 0,
  },
  cursor = {
    -- Cycling local workspaces (Super+Shift+scroll) dispatches a
    -- focus change; Hyprland's default warp-cursor-to-focused-window
    -- behavior then flings the pointer across the screen, landing it
    -- outside the area the next scroll tick needs to hit and making
    -- the opposite direction look broken.
    no_warps = true,
  },
  binds = {
    pass_mouse_when_bound = false,
    -- A non-zero delay lets Super + wheel leak through to the focused app.
    scroll_event_delay = 0,
  },
})

-- Durations are in deciseconds: keep the interface responsive.
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default" })

-- Each physical display owns five local workspace slots. Hyprland
-- workspace IDs remain global, so the right display uses 6–10 while
-- Quickshell presents them as 1–5.
for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2" })
  hl.workspace_rule({ workspace = tostring(i + 5), monitor = "HDMI-A-1" })
end

-- The power menu is the only full-screen shell surface that blurs
-- the desktop. Its namespace keeps the pill and hover widgets crisp.
hl.layer_rule({
  match = { namespace = "muggynix-power-menu" },
  blur = true,
  ignore_alpha = 0.1,
})

local mod = "SUPER"

-- Super+F alternates between true fullscreen and maximized instead
-- of dropping a fullscreen window back into the scrolling layout.
local function toggle_true_fullscreen()
  local active = hl.get_active_window()
  if active and active.fullscreen == 2 then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set", layout_aware = true }))
  else
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set", layout_aware = true }))
  end
end

-- Super+Space owns the maximized state. In particular it must turn a
-- true fullscreen window (state 2) into maximized (state 1), rather
-- than asking Hyprland to toggle a different fullscreen mode.
local function toggle_maximized()
  local active = hl.get_active_window()
  if active and active.fullscreen == 1 then
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0, action = "set", layout_aware = true }))
  else
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set", layout_aware = true }))
  end
end

-- Each call gets its own `throttled` upvalue, so the four scroll
-- binds below (column move x2, workspace cycle x2) debounce
-- independently. A shared flag let cycling one direction eat the
-- immediate attempt to reverse it, since both directions raced for
-- the same cooldown window.
local function throttled_dsp(dsp)
  local throttled = false
  return function()
    if throttled then return end

    throttled = true
    -- pcall so a dispatch error (e.g. the cycle script exiting on an
    -- out-of-range workspace) can't skip the reset below and leave
    -- this bind permanently dead until the next config reload.
    local ok, err = pcall(hl.dispatch, dsp)
    if not ok then
      print("throttled_dsp: dispatch failed: " .. tostring(err))
    end
    hl.timer(function()
      throttled = false
    end, {
      timeout = 200,
      type = "oneshot",
    })
  end
end

hl.on("hyprland.start", function()
  -- The start event may be replayed after a Hyprland config reload.
  -- Do not create a second panel for the same Quickshell config.
  hl.exec_cmd("qs --no-duplicate -c muggy")
  hl.exec_cmd("handy --start-hidden")
end)

hl.bind(mod .. " + D", hl.dsp.exec_cmd("qs -c muggy ipc call shell toggleLauncher"))
hl.bind(mod .. " + O", hl.dsp.exec_cmd("qs -c muggy ipc call shell toggleOverview"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("qs -c muggy ipc call shell toggleThemeManager"))
hl.bind(mod .. " + BACKSPACE", hl.dsp.exec_cmd("qs -c muggy ipc call shell togglePowerMenu"))
hl.bind("F1", hl.dsp.exec_cmd("handy --toggle-transcription"))
hl.bind("F1", hl.dsp.exec_cmd("handy --toggle-transcription"), { release = true })
hl.bind(mod .. " + T", hl.dsp.exec_cmd("@kitty@/bin/kitty @fish@/bin/fish"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("thunar"))
hl.bind(mod .. " + F", toggle_true_fullscreen)
hl.bind(mod .. " + SPACE", toggle_maximized)
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + R", hl.dsp.exec_cmd("muggy-screen-record start"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("muggy-screen-record stop"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("muggy-screenshot"))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
-- "move +/-col" relocates every window a column over and reassigns
-- active to whatever lands at the reference position — repeated
-- scrolling cycles through all windows instead of just scrolling
-- the view. The scrolling layout's "focus" message takes "l"/"r"
-- (previous/next column), not "+col"/"-col" (that argument form is
-- only for "move") — moves the active column without touching any
-- window's position.
hl.bind(mod .. " + mouse_down", throttled_dsp(hl.dsp.layout("focus r")))
hl.bind(mod .. " + mouse_up", throttled_dsp(hl.dsp.layout("focus l")))
hl.bind(mod .. " + SHIFT + mouse_down", throttled_dsp(hl.dsp.exec_cmd("local-workspace cycle next")))
hl.bind(mod .. " + SHIFT + mouse_up", throttled_dsp(hl.dsp.exec_cmd("local-workspace cycle previous")))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

for i = 1, 5 do
  hl.bind(mod .. " + " .. i, hl.dsp.exec_cmd("local-workspace focus " .. i))
  hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.exec_cmd("local-workspace move " .. i))
end

-- Scratchpads: a special workspace that floats over the current one. The key
-- spawns the program on first use, then shows/hides it. Toggling an empty
-- special workspace only dims the screen.
local function scratchpad(key, name, command)
  hl.window_rule({
    name = "scratch-" .. name,
    match = { class = "^scratch-" .. name .. "$" },
    workspace = "special:" .. name,
    float = true,
    -- kitty asks to open maximized, which overrides size and center.
    suppress_event = "maximize",
    size = "monitor_w*0.7 monitor_h*0.6",
    center = true,
  })
  hl.bind(mod .. " + " .. key, function()
    for _, w in ipairs(hl.get_windows()) do
      if w.class == "scratch-" .. name then
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
        return
      end
    end
    hl.dispatch(hl.dsp.exec_cmd(command))
  end)
end

scratchpad("S", "term", "@kitty@/bin/kitty --class scratch-term @fish@/bin/fish")
scratchpad("I", "irc", "@kitty@/bin/kitty --class scratch-irc weechat")
