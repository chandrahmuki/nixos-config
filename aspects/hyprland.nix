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
      restartQuickshell = pkgs.writeShellApplication {
        name = "restart-quickshell";
        runtimeInputs = [pkgs.quickshell pkgs.gnugrep pkgs.coreutils];
        text = ''
          qs --config muggy kill --any-display || true

          for _ in $(seq 1 50); do
            if ! qs --config muggy list --json --any-display 2>/dev/null | grep -q '"id"'; then
              qs --daemonize --no-duplicate --config muggy
              exit 0
            fi
            sleep 0.1
          done

          echo "Quickshell did not stop within 5 seconds." >&2
          exit 1
        '';
      };
      localWorkspace = pkgs.writeShellApplication {
        name = "local-workspace";
        runtimeInputs = [pkgs.hyprland pkgs.jq];
        text = ''
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
        '';
      };
    in {
      home.packages = [
        restartQuickshell
        localWorkspace
        pkgs.grim
        pkgs.slurp
      ];

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
        # Hyprland starts the shell below, only in its own session.
        systemd.enable = false;
      };

      # Development configuration: keep the active QML as a direct link to
      # this checkout so Quickshell can observe edits and hot-reload them.
      # The link itself remains declared by Home Manager.
      xdg.configFile."quickshell/muggy".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-config/quickshell";

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
            blur = {
              enabled = true,
              size = 18,
              passes = 3,
            },
          },
          scrolling = {
            fullscreen_on_one_column = true,
          },
          misc = {
            force_default_wallpaper = -1,
            disable_hyprland_logo = true,
            mouse_move_focuses_monitor = false,
          },
          input = {
            kb_layout = "us",
            follow_mouse = 0,
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
        local scrollThrottled = false

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
          hl.exec_cmd("handy --start-hidden")
        end)

        hl.bind(mod .. " + D", hl.dsp.exec_cmd("qs -c muggy ipc call shell toggleLauncher"))
        hl.bind(mod .. " + O", hl.dsp.exec_cmd("qs -c muggy ipc call shell toggleOverview"))
        hl.bind(mod .. " + BACKSPACE", hl.dsp.exec_cmd("qs -c muggy ipc call shell togglePowerMenu"))
        hl.bind("F1", hl.dsp.exec_cmd("handy --toggle-transcription"))
        hl.bind("F1", hl.dsp.exec_cmd("handy --toggle-transcription"), { release = true })
        hl.bind(mod .. " + T", hl.dsp.exec_cmd("foot"))
        hl.bind(mod .. " + B", hl.dsp.exec_cmd("thunar"))
        hl.bind(mod .. " + F", toggle_true_fullscreen)
        hl.bind(mod .. " + SPACE", toggle_maximized)
        hl.bind(mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
        hl.bind(mod .. " + Q", hl.dsp.window.close())
        hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("sh -c 'selection=$(slurp); [ -n \"$selection\" ] && mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots && grim -g \"$selection\" ${config.home.homeDirectory}/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png'"))
        hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
        hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
        hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
        hl.bind(mod .. " + mouse_down", throttled_dsp(hl.dsp.layout("move +col")))
        hl.bind(mod .. " + mouse_up", throttled_dsp(hl.dsp.layout("move -col")))
        hl.bind(mod .. " + SHIFT + mouse_down", throttled_dsp(hl.dsp.exec_cmd("local-workspace cycle next")))
        hl.bind(mod .. " + SHIFT + mouse_up", throttled_dsp(hl.dsp.exec_cmd("local-workspace cycle previous")))
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

        for i = 1, 5 do
          hl.bind(mod .. " + " .. i, hl.dsp.exec_cmd("local-workspace focus " .. i))
          hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.exec_cmd("local-workspace move " .. i))
        end
      '';
    };
  };
}
