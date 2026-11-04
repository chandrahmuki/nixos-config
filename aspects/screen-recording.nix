{den, ...}: {
  den.aspects.screen-recording.nixos = {
    pkgs,
    username,
    ...
  }: let
    screenRecorderIcon = ../quickshell/assets/screen-recorder.svg;
    screenRecorder = pkgs.writeShellApplication {
      name = "muggy-screen-record";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gpu-screen-recorder
        pkgs.gnused
        pkgs.hyprland
        pkgs.jq
        pkgs.libnotify
        pkgs.slurp
        pkgs.systemd
        pkgs.xdg-user-dirs
      ];
      text = ''
        set -euo pipefail

        unit="muggy-screen-recorder.service"
        runtime_dir="''${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}/muggy-screen-recorder"
        socket="$runtime_dir/control.sock"
        state_file="$runtime_dir/current"
        region_file="$runtime_dir/region"

        notify() {
          urgency="$1"
          title="$2"
          body="$3"
          notify-send --app-name="Muggy Recorder" --replace-id=7410 \
            --urgency="$urgency" --icon="${screenRecorderIcon}" "$title" "$body"
        }

        is_recording() {
          gsr-cli -ipc "$socket" status >/dev/null 2>&1
        }

        # `region` asks for a zone with slurp, like muggy-screenshot; `screen` films the
        # whole focused monitor.
        start_recording() {
          mode="$1"
          if is_recording || systemctl --user is-active --quiet "$unit"; then
            notify normal "Enregistrement déjà actif" "Utilise Super+Shift+R pour l'arrêter."
            return 0
          fi

          region=""
          if [ "$mode" = region ]; then
            region="$(slurp -f "%wx%h+%x+%y")" || return 0
            [ -n "$region" ] || return 0
          fi

          mkdir -p "$runtime_dir"
          rm -f "$socket" "$state_file"
          printf '%s\n' "$region" > "$region_file"
          systemctl --user reset-failed "$unit" >/dev/null 2>&1 || true
          systemctl --user start "$unit"

          for _attempt in $(seq 1 50); do
            if is_recording; then
              output="$(sed -n '1p' "$state_file")"
              monitor="$(sed -n '2p' "$state_file")"
              area="$(sed -n '3p' "$state_file")"
              notify low "Enregistrement démarré" "''${area:-$monitor} • audio système • $(basename "$output")"
              return 0
            fi
            sleep 0.1
          done

          systemctl --user stop "$unit" >/dev/null 2>&1 || true
          notify critical "Échec de l'enregistrement" "GPU Screen Recorder n'a pas démarré."
          return 1
        }

        stop_recording() {
          if ! is_recording; then
            notify normal "Aucun enregistrement actif" "Super+R démarre une nouvelle capture."
            return 0
          fi

          if output="$(gsr-cli -ipc "$socket" stop)" && [ -s "$output" ]; then
            systemctl --user stop "$unit" >/dev/null 2>&1 || true
            notify normal "Enregistrement sauvegardé" "$(basename "$output") • $(dirname "$output")"
            printf '%s\n' "$output"
            return 0
          fi

          notify critical "Échec de la sauvegarde" "Le fichier vidéo n'a pas pu être finalisé."
          return 1
        }

        run_recorder() {
          video_root="$(xdg-user-dir VIDEOS 2>/dev/null || true)"
          if [ -z "$video_root" ] || [ "$video_root" = "$HOME" ]; then
            video_root="$HOME/Videos"
          fi
          output_dir="$video_root/Recordings"
          mkdir -p "$output_dir" "$runtime_dir"

          region="$(cat "$region_file" 2>/dev/null || true)"
          if [ -n "$region" ]; then
            # The monitor under the top-left corner of the zone (global layout coordinates).
            x="$(printf '%s' "$region" | sed 's/^[0-9]*x[0-9]*+\([0-9]*\)+[0-9]*$/\1/')"
            y="$(printf '%s' "$region" | sed 's/^[0-9]*x[0-9]*+[0-9]*+\([0-9]*\)$/\1/')"
            monitor="$(hyprctl monitors -j | jq -er --argjson x "$x" --argjson y "$y" \
              '.[] | select(.x <= $x and $x < .x + (.width / .scale) and .y <= $y and $y < .y + (.height / .scale)) | .name' | head -n 1)"
            capture_args=(-w region -region "$region")
          else
            monitor="$(hyprctl monitors -j | jq -er '.[] | select(.focused == true) | .name' | head -n 1)"
            capture_args=(-w "$monitor" -s 2560x1440)
          fi
          timestamp="$(date +%Y%m%d-%H%M%S)"
          output="$output_dir/recording-$timestamp.mp4"
          printf '%s\n%s\n%s\n' "$output" "$monitor" "$region" > "$state_file.tmp"
          mv "$state_file.tmp" "$state_file"

          exec gpu-screen-recorder \
            "''${capture_args[@]}" \
            -f 60 \
            -a default_output \
            -k h264 \
            -ac aac \
            -ab 192 \
            -q high \
            -fm vfr \
            -cursor yes \
            -keyint 2 \
            -c mp4 \
            -ipc "$socket" \
            -o "$output"
        }

        case "''${1:-status}" in
          start) start_recording region ;;
          start-screen) start_recording screen ;;
          stop) stop_recording ;;
          status)
            if is_recording; then
              printf 'recording\n'
            else
              printf 'idle\n'
            fi
            ;;
          run) run_recorder ;;
          *)
            printf 'Usage: muggy-screen-record {start|start-screen|stop|status}\n' >&2
            exit 2
            ;;
        esac
      '';
    };
  in {
    programs.gpu-screen-recorder.enable = true;

    home-manager.users.${username} = {
      home.packages = [screenRecorder];

      systemd.user.services.muggy-screen-recorder = {
        Unit = {
          Description = "Muggy instant screen recorder";
          After = ["graphical-session.target" "pipewire.service"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          Type = "exec";
          ExecStart = "${screenRecorder}/bin/muggy-screen-record run";
          KillSignal = "SIGINT";
          TimeoutStopSec = 20;
          Restart = "no";
        };
      };
    };
  };
}
