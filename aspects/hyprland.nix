{den, ...}: {
  # Hyprland deliberately lives alongside GNOME: selecting it in tuigreet does
  # not alter the existing GNOME/Walker session.
  den.aspects.hyprland.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Needed for screen sharing and file pickers in the Hyprland session.
    xdg.portal = {
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      config.hyprland.default = ["hyprland" "gtk"];
    };

    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: let
      wallpaper = ../wallpapers/nixos_neon_souterrain.png;
    in {
      wayland.windowManager.hyprland = {
        enable = true;
        # The actual Lua file is managed below through xdg.configFile.
        # Keep Home Manager's empty legacy file explicit to avoid a stateVersion
        # warning and to prevent it from competing for hyprland.lua.
        configType = "hyprlang";
        # UWSM owns the session lifecycle; a second Home Manager systemd
        # integration would race it.
        systemd.enable = false;
      };

      programs.quickshell = {
        enable = true;
        activeConfig = "muggy";
        configs.muggy = ../quickshell;
        # Hyprland starts the shell below, only in its own session.
        systemd.enable = false;
      };

      programs.hyprlock.enable = true;

      services.hyprpaper = {
        enable = true;
        settings = {
          preload = ["${wallpaper}"];
          wallpaper = [",${wallpaper}"];
        };
      };

      # Hypridle performs the security-sensitive idle policy; Quickshell only
      # provides the shell UI and can invoke `hyprlock` from a future menu.
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 600;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 900;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

      # Keep this short and explicit.  The scroll layout is native in the
      # installed Hyprland; no version-locked layout plugin is involved.
      xdg.configFile."hypr/hyprland.lua".text = ''
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
            blur = { enabled = false },
          },
          scrolling = {
            fullscreen_on_one_column = true,
          },
          misc = {
            force_default_wallpaper = -1,
            disable_hyprland_logo = true,
          },
          input = {
            kb_layout = "us",
            follow_mouse = 1,
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

        local mod = "SUPER"
        local scrollThrottled = false

        local function throttled_dsp(dsp)
          return function()
            if scrollThrottled then return end

            scrollThrottled = true
            hl.dispatch(dsp)
            hl.timer(function()
              scrollThrottled = false
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
        end)

        hl.bind(mod .. " + D", hl.dsp.exec_cmd("qs -c muggy ipc call shell toggleLauncher"))
        hl.bind(mod .. " + O", hl.dsp.exec_cmd("qs -c muggy ipc call shell toggleOverview"))
        hl.bind(mod .. " + T", hl.dsp.exec_cmd("foot"))
        hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", layout_aware = true }))
        hl.bind(mod .. " + SPACE", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
        hl.bind(mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
        hl.bind(mod .. " + Q", hl.dsp.window.close())
        hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
        hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
        hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
        hl.bind(mod .. " + mouse_down", throttled_dsp(hl.dsp.layout("move +col")))
        hl.bind(mod .. " + mouse_up", throttled_dsp(hl.dsp.layout("move -col")))
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

        for i = 1, 10 do
          local key = i % 10
          hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
          hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
        end
      '';
    };
  };
}
