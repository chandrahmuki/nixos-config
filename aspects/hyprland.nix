{den, ...}: {
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
      gnomeLinesWallpaper = ../wallpapers/gnome_00_2560x1440.png;
      gnomeGradientWallpaper = ../wallpapers/wallpaperGnome.png;
      muggynixWallpaperDir = ../quickshell/assets/wallpapers;
      muggyTheme = pkgs.writeShellApplication {
        name = "muggy-theme";
        runtimeInputs = [pkgs.hyprland pkgs.coreutils pkgs.glib pkgs.jq pkgs.kitty pkgs.matugen pkgs.papirus-folders];
        text = ''
          set -euo pipefail

          state_root="''${XDG_STATE_HOME:-$HOME/.local/state}/muggy"
          state_file="$state_root/theme"

          current_theme() {
            if [ -r "$state_file" ]; then cat "$state_file"; else printf '%s\n' muggy; fi
          }

          # Shared by apply_theme and preview_scheme so the wallpaper, mode,
          # and --prefer choice per theme lives in exactly one place.
          resolve_background() {
            theme="$1"
            # Matugen picks its palette from whichever colour in the image
            # best matches "prefer" — not from the curated Quickshell swatch.
            # "saturation" (the default) picks the most vivid hue, which for
            # most photos is the one that actually reads as that theme's
            # colour; a few images needed a different rule to land on the
            # blue/green the theme is named for instead of an incidental
            # sky or parchment tone.
            prefer="saturation"
            theme_mode="dark"
            theme_accent=""
            case "$theme" in
              muggy) background="${wallpaper}" ;;
              gnome-lines) background="${gnomeLinesWallpaper}"; prefer="lightness" ;;
              gnome-gradient) background="${gnomeGradientWallpaper}"; prefer="darkness" ;;
              catppuccin) background="${muggynixWallpaperDir}/quattro-catppuccin.jpg"; theme_accent="#89b4fa" ;;
              catppuccin-latte) background="${muggynixWallpaperDir}/quattro-catppuccin-latte.jpg"; theme_mode="light"; theme_accent="#1e66f5" ;;
              ethereal) background="${muggynixWallpaperDir}/quattro-ethereal.jpg"; theme_accent="#7d82d9" ;;
              everforest) background="${muggynixWallpaperDir}/quattro-everforest.jpg"; theme_accent="#7fbbb3" ;;
              flexoki-light) background="${muggynixWallpaperDir}/muggynix-flexoki-light.jpg"; theme_mode="light"; theme_accent="#205EA6" ;;
              gruvbox) background="${muggynixWallpaperDir}/quattro-gruvbox.jpg"; theme_accent="#7daea3" ;;
              hackerman) background="${muggynixWallpaperDir}/quattro-hackerman.jpg"; theme_accent="#82FB9C" ;;
              kanagawa) background="${muggynixWallpaperDir}/quattro-kanagawa.jpg"; theme_accent="#dcd7ba" ;;
              last-horizon) background="${muggynixWallpaperDir}/quattro-last-horizon.jpg"; theme_accent="#b59790" ;;
              lumon) background="${muggynixWallpaperDir}/quattro-lumon.jpg"; theme_accent="#8bc9eb" ;;
              lupine) background="${muggynixWallpaperDir}/muggynix-lupine.jpg"; theme_mode="light"; theme_accent="#3264eb" ;;
              matte-black) background="${muggynixWallpaperDir}/quattro-matte-black.jpg"; theme_accent="#e68e0d" ;;
              miasma) background="${muggynixWallpaperDir}/quattro-miasma.jpg"; theme_accent="#78824b" ;;
              nord) background="${muggynixWallpaperDir}/quattro-nord.jpg"; theme_accent="#81a1c1" ;;
              osaka-jade) background="${muggynixWallpaperDir}/quattro-osaka-jade.jpg"; theme_accent="#509475" ;;
              retro-82) background="${muggynixWallpaperDir}/quattro-retro-82.jpg"; theme_accent="#faa968" ;;
              ristretto) background="${muggynixWallpaperDir}/quattro-ristretto.jpg"; theme_accent="#f38d70" ;;
              rose-pine) background="${muggynixWallpaperDir}/muggynix-rose-pine.jpg"; theme_mode="light"; theme_accent="#56949f" ;;
              solitude) background="${muggynixWallpaperDir}/quattro-solitude.jpg"; theme_accent="#798186" ;;
              tokyo-night) background="${muggynixWallpaperDir}/quattro-tokyo-night.jpg"; theme_accent="#7aa2f7" ;;
              vantablack) background="${muggynixWallpaperDir}/quattro-vantablack.jpg"; theme_accent="#8d8d8d" ;;
              white) background="${muggynixWallpaperDir}/quattro-white.jpg"; theme_mode="light"; theme_accent="#6e6e6e" ;;
              *) echo "Unknown Muggy theme: $theme" >&2; exit 2 ;;
            esac
          }

          # Quattro's accent is curated in colors.toml. Keep that exact accent
          # while Matugen derives the rest of the palette from its wallpaper.
          apply_theme_accent() {
            if [ -z "$theme_accent" ]; then
              cat
            elif [ "$theme" = solitude ]; then
              # Solitude's official Quattro colors.toml is deliberately
              # monochrome. Matugen samples the wallpaper's warm highlights,
              # which otherwise gives GTK an olive background and pink errors.
              jq --arg accent "$theme_accent" '
                .colors.primary.dark.color = $accent
                | .colors.primary.default.color = $accent
                | .colors.primary.light.color = $accent
                | .colors.primary_container.dark.color = "#343d41"
                | .colors.on_primary.dark.color = "#101315"
                | .colors.on_primary_container.dark.color = "#cacccc"
                | .colors.background.dark.color = "#101315"
                | .colors.on_background.dark.color = "#cacccc"
                | .colors.surface.dark.color = "#101315"
                | .colors.on_surface.dark.color = "#cacccc"
                | .colors.surface_container.dark.color = "#101315"
                | .colors.surface_container_low.dark.color = "#0c0e10"
                | .colors.surface_container_high.dark.color = "#343d41"
                | .colors.error.dark.color = "#de6145"
                | .colors.success.dark.color = "#9fa5a9"
                | .colors.warning.dark.color = "#d9dbdc"
                | .colors.secondary.dark.color = "#707070"
                | .colors.tertiary.dark.color = "#9fa5a9"
                | .colors.primary_fixed.dark.color = "#9a9a9a"
                | .colors.primary_fixed_dim.dark.color = "#5d6367"
                | .colors.secondary_fixed.dark.color = "#707070"
                | .colors.secondary_fixed_dim.dark.color = "#4b4e55"
                | .colors.tertiary_fixed.dark.color = "#9fa5a9"
                | .colors.tertiary_fixed_dim.dark.color = "#798186"
                | .colors.outline.dark.color = "#4b4e55"
                | .colors.outline_variant.dark.color = "#4b4e55"
              '
            else
              jq --arg accent "$theme_accent" '
                .colors.primary.dark.color = $accent
                | .colors.primary.default.color = $accent
                | .colors.primary.light.color = $accent
              '
            fi
          }

          # Fast, side-effect-free: resolves the theme's wallpaper and runs
          # Matugen with a caller-chosen --type, printing just the primary
          # colour. Used by the theme deck's live scheme-algorithm swatches,
          # which call this once per candidate algorithm on every carousel
          # selection — no state write, no Kitty/GTK push, no border change.
          preview_scheme() {
            theme="$1"
            scheme="''${2:-scheme-vibrant}"
            resolve_background "$theme"
            matugen image "$background" --mode "$theme_mode" --prefer "$prefer" --type "$scheme" --json hex \
              | apply_theme_accent \
              | jq -r '.colors.primary.dark.color'
          }

          apply_theme() {
            theme="$1"
            scheme="''${2:-scheme-vibrant}"
            resolve_background "$theme"

            mkdir -p "$state_root"
            printf '%s\n' "$theme" > "$state_file.tmp"
            mv "$state_file.tmp" "$state_file"
            # Wallpaper display itself is Quickshell's own BackgroundWindow now
            # (reacting to activeThemeId directly) — hyprpaper is gone, so
            # there is nothing to push the image to here.

            # Matugen is deliberately non-interactive here: a UI action must
            # never wait for a terminal prompt when the image has several
            # suitable source colours.
            # $scheme (default scheme-vibrant, picked in the theme deck)
            # keeps the same hue matugen already chose via $prefer but
            # controls how far it pushes saturation/contrast from there —
            # the tonal-spot Matugen default tended to read as washed-out.
            palette="$(matugen image "$background" --mode "$theme_mode" --prefer "$prefer" --type "$scheme" --json hex | apply_theme_accent)"
            primary="$(printf '%s' "$palette" | jq -r '.colors.primary.dark.color | ltrimstr("#")')"
            outline="$(printf '%s' "$palette" | jq -r '.colors.outline_variant.dark.color | ltrimstr("#")')"

            # Kitty imports this mutable Matugen fragment. After an atomic
            # update, remote control applies it to all live Kitty windows.
            cache_root="''${XDG_CACHE_HOME:-$HOME/.cache}/muggy"
            mkdir -p "$cache_root"
            kitty_theme="$cache_root/kitty-theme.conf"
            kitty_theme_tmp="$(mktemp "$cache_root/kitty-theme.XXXXXX")"
            printf '%s' "$palette" | jq -r '
              def c($name): .colors[$name].dark.color;
              "background \(c("background"))",
              "foreground \(c("on_surface"))",
              "cursor \(c("primary"))",
              "selection_background \(c("primary_container"))",
              "selection_foreground \(c("on_primary_container"))",
              # Terminal TUIs commonly paint their canvas with ANSI black.
              # Keep it aligned with the actual Matugen background instead of
              # surface_container_highest or primary_container, both of which
              # carry enough hue from the source colour to read green.
              "color0 \(c("background"))",
              "color1 \(c("error"))",
              "color2 \(c("primary"))",
              "color3 \(c("secondary"))",
              "color4 \(c("tertiary"))",
              "color5 \(c("primary_fixed"))",
              "color6 \(c("secondary_fixed"))",
              "color7 \(c("on_surface"))",
              "color8 \(c("outline"))",
              "color9 \(c("error"))",
              "color10 \(c("primary_fixed"))",
              "color11 \(c("secondary_fixed"))",
              "color12 \(c("tertiary_fixed"))",
              "color13 \(c("primary_fixed"))",
              "color14 \(c("secondary"))",
              "color15 \(c("on_background"))"
            ' > "$kitty_theme_tmp"
            mv "$kitty_theme_tmp" "$kitty_theme"
            # Kitty suffixes a bare listen_on path with its own PID (our
            # config now spells that out via {kitty_pid}), so there is no
            # single fixed socket to target: push to every live window.
            for kitty_socket in "/run/user/$(id -u)"/kitty-*; do
              [ -S "$kitty_socket" ] || continue
              kitty @ --to "unix:$kitty_socket" set-colors --all --configured "$kitty_theme" >/dev/null 2>&1 || true
            done

            # GTK3/GTK4 both import this small final CSS file after their
            # declarative Stylix base. This gives Matugen precedence without
            # making Nix-managed files mutable.
            gtk_css_tmp="$(mktemp "$cache_root/gtk-matugen.css.XXXXXX")"
            printf '%s' "$palette" | jq -r '
              def c($name): .colors[$name].dark.color;
              "@define-color accent_color \(c("primary"));",
              "@define-color accent_bg_color \(c("primary"));",
              "@define-color accent_fg_color \(c("on_primary"));",
              "@define-color destructive_color \(c("error"));",
              "@define-color destructive_bg_color \(c("error"));",
              "@define-color destructive_fg_color \(c("on_error"));",
              "@define-color success_color \(c("primary_fixed"));",
              "@define-color success_bg_color \(c("primary_fixed"));",
              "@define-color success_fg_color \(c("on_primary_fixed"));",
              "@define-color warning_color \(c("secondary"));",
              "@define-color warning_bg_color \(c("secondary"));",
              "@define-color warning_fg_color \(c("on_secondary"));",
              "@define-color error_color \(c("error"));",
              "@define-color error_bg_color \(c("error"));",
              "@define-color error_fg_color \(c("on_error"));",
              "@define-color window_bg_color \(c("background"));",
              "@define-color window_fg_color \(c("on_background"));",
              "@define-color view_bg_color \(c("surface"));",
              "@define-color view_fg_color \(c("on_surface"));",
              "@define-color headerbar_bg_color \(c("surface_container"));",
              "@define-color headerbar_fg_color \(c("on_surface"));",
              "@define-color headerbar_backdrop_color @window_bg_color;",
              "@define-color sidebar_bg_color \(c("surface_container_low"));",
              "@define-color sidebar_fg_color \(c("on_surface"));",
              "@define-color sidebar_backdrop_color @window_bg_color;",
              "@define-color card_bg_color \(c("surface_container_high"));",
              "@define-color card_fg_color \(c("on_surface"));",
              "@define-color dialog_bg_color \(c("surface_container"));",
              "@define-color dialog_fg_color \(c("on_surface"));",
              "@define-color popover_bg_color \(c("surface_container_high"));",
              "@define-color popover_fg_color \(c("on_surface"));",
              "@define-color theme_selected_bg_color \(c("primary"));",
              "@define-color theme_selected_fg_color \(c("on_primary"));",
              "@define-color theme_fg_color \(c("on_surface"));",
              "@define-color theme_bg_color \(c("background"));"
            ' > "$gtk_css_tmp"
            mv "$gtk_css_tmp" "$cache_root/gtk-matugen.css"

            # Papirus-folders only ships a fixed palette (see `-l`), not
            # arbitrary hex, so this is a hand-picked nearest match per
            # theme rather than anything derived from $palette. Best-effort:
            # a missing/older Papirus build should never fail the apply.
            case "$theme" in
              muggy) folder_color="cyan" ;;
              gnome-lines|gnome-gradient|rose-pine) folder_color="pink" ;;
              catppuccin|catppuccin-latte|lupine|lumon) folder_color="blue" ;;
              ethereal|last-horizon|tokyo-night) folder_color="indigo" ;;
              everforest|hackerman|miasma) folder_color="green" ;;
              flexoki-light|retro-82) folder_color="orange" ;;
              gruvbox|ristretto) folder_color="brown" ;;
              kanagawa) folder_color="bluegrey" ;;
              matte-black|solitude) folder_color="grey" ;;
              nord) folder_color="nordic" ;;
              osaka-jade) folder_color="teal" ;;
              vantablack) folder_color="black" ;;
              white) folder_color="white" ;;
              *) echo "Unknown Muggy theme folder color: $theme" >&2; exit 2 ;;
            esac
            if [ -n "$folder_color" ]; then
              papirus-folders -C "$folder_color" -t Papirus-Dark -u >/dev/null 2>&1 || true
            fi

            # libadwaita only notices its CSS replacement reliably after a
            # color-scheme transition. Restore the user's dark preference.
            gsettings set org.gnome.desktop.interface color-scheme prefer-light
            gsettings set org.gnome.desktop.interface color-scheme prefer-dark

            # This configuration is Lua-based, so legacy `hyprctl keyword`
            # calls do not work. Apply the generated border colours through
            # Hyprland's Lua evaluator instead. A long-lived Quickshell
            # process can inherit a dead instance signature after Hyprland
            # restarts, so resolve the newest live lock for every apply.
            hypr_signature=""
            newest_hypr_lock=0
            for lock in "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/hypr/*/hyprland.lock; do
              [ -r "$lock" ] || continue
              hypr_pid="$(sed -n '1p' "$lock" 2>/dev/null || true)"
              lock_mtime="$(stat -c %Y "$lock" 2>/dev/null || printf '0')"
              if [ -n "$hypr_pid" ] && kill -0 "$hypr_pid" 2>/dev/null \
                && [ "$lock_mtime" -ge "$newest_hypr_lock" ]; then
                hypr_dir="''${lock%/hyprland.lock}"
                hypr_signature="''${hypr_dir##*/}"
                newest_hypr_lock="$lock_mtime"
              fi
            done
            if [ -n "$hypr_signature" ]; then
              HYPRLAND_INSTANCE_SIGNATURE="$hypr_signature" \
                hyprctl eval "hl.config({ general = { col = { active_border = \"rgb($primary)\", inactive_border = \"rgb($outline)\" } }, group = { col = { border_active = \"rgb($primary)\" } } })" >/dev/null \
                || echo "Warning: could not update Hyprland border colours" >&2
            else
              echo "Warning: no live Hyprland signature found; skipped border colours" >&2
            fi

            # Quickshell consumes this one-line JSON through SplitParser.
            # Keep it as the final stdout payload; diagnostics stay on stderr.
            # Quickshell's SplitParser receives line-delimited messages. Keep
            # the palette as one complete JSON line or it will try to parse
            # each pretty-printed fragment independently.
            printf '%s\n' "$palette" | jq -c .
          }

          case "''${1:-current}" in
            current) current_theme ;;
            apply) apply_theme "''${2:?Usage: muggy-theme apply <theme> [scheme]}" "''${3:-scheme-vibrant}" ;;
            preview-scheme) preview_scheme "''${2:?Usage: muggy-theme preview-scheme <theme> <scheme>}" "''${3:-scheme-vibrant}" ;;
            *) echo "Usage: muggy-theme {current|apply <theme> [scheme]|preview-scheme <theme> <scheme>}" >&2; exit 2 ;;
          esac
        '';
      };
      restartQuickshell = pkgs.writeShellApplication {
        name = "restart-quickshell";
        runtimeInputs = [pkgs.quickshell pkgs.gnugrep pkgs.coreutils];
        text = ''
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
              hypr_dir="''${lock%/hyprland.lock}"
              hypr_signature="''${hypr_dir##*/}"
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
        muggyTheme
        pkgs.grim
        pkgs.slurp
        pkgs.wl-clipboard
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

      # No hyprpaper: the wallpaper is Quickshell's own BackgroundWindow now
      # (windows/BackgroundWindow.qml), so theme transitions can animate it
      # directly instead of fighting a second client for the Background
      # layer — that fight is exactly why hyprpaper was here before, and why
      # its reveal effect never reliably showed up on top of it.
      #
      # Removing our own `services.hyprpaper` block wasn't the whole story:
      # Stylix provisions hyprpaper on its own too (it wires up whatever
      # wallpaper daemon fits the session so `stylix.image` gets applied),
      # entirely independent of that block. That's the actual reason the
      # unit kept reappearing after every switch — disabled explicitly here,
      # same as the other per-app Stylix targets below.
      stylix.targets.hyprpaper.enable = lib.mkForce false;
      # The target flag above only stops Stylix from *configuring*
      # hyprpaper's wallpaper — Stylix's hyprpaper target still turns on
      # home-manager's own `services.hyprpaper` regardless, which is what
      # actually creates the systemd unit. Force that off too.
      services.hyprpaper.enable = lib.mkForce false;

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
        hl.bind(mod .. " + T", hl.dsp.exec_cmd("${pkgs.kitty}/bin/kitty ${pkgs.fish}/bin/fish"))
        hl.bind(mod .. " + B", hl.dsp.exec_cmd("thunar"))
        hl.bind(mod .. " + F", toggle_true_fullscreen)
        hl.bind(mod .. " + SPACE", toggle_maximized)
        hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
        hl.bind(mod .. " + Q", hl.dsp.window.close())
        hl.bind(mod .. " + R", hl.dsp.exec_cmd("muggy-screen-record start"))
        hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("muggy-screen-record stop"))
        hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("sh -c 'selection=$(slurp); [ -n \"$selection\" ] || exit; mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots; file=${config.home.homeDirectory}/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png; grim -g \"$selection\" \"$file\" && wl-copy --type image/png < \"$file\" && ${pkgs.libnotify}/bin/notify-send --app-name=Screenshot --icon=\"$file\" -t 3000 Capture \"Copiée et enregistrée : $(basename \"$file\")\"'"))
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

        -- Scratchpad terminal: a special workspace that floats over the
        -- current one. Super+S spawns the kitty that the rule below sends
        -- into it on first use, then shows/hides it. Toggling an empty
        -- special workspace only dims the screen.
        hl.window_rule({
          name = "scratch-term",
          match = { class = "^scratch-term$" },
          workspace = "special:term",
          float = true,
          -- kitty asks to open maximized, which overrides size and center.
          suppress_event = "maximize",
          size = "monitor_w*0.7 monitor_h*0.6",
          center = true,
        })
        hl.bind(mod .. " + S", function()
          for _, w in ipairs(hl.get_windows()) do
            if w.class == "scratch-term" then
              hl.dispatch(hl.dsp.workspace.toggle_special("term"))
              return
            end
          end
          hl.dispatch(hl.dsp.exec_cmd("${pkgs.kitty}/bin/kitty --class scratch-term ${pkgs.fish}/bin/fish"))
        end)
      '';
    };
  };
}
