{ pkgs, ... }:
let
  # Wrapper générique pour xdg-open qui force le focus sur l'app cible via niri msg
  # Appelle le VRAI xdg-open par chemin complet Nix (pas de récursion)
  # Fonctionne avec TOUTES les apps, sur tous les moniteurs et workspaces
  xdg-open-with-focus = pkgs.writeShellScriptBin "xdg-open" ''
    # Déterminer le fichier .desktop cible à partir du type MIME / scheme de l'URL
    URL="$1"
    DESKTOP=""

    if echo "$URL" | grep -qE '^https?://'; then
      DESKTOP=$(${pkgs.xdg-utils}/bin/xdg-mime query default x-scheme-handler/https 2>/dev/null)
    elif echo "$URL" | grep -qE '^mailto:'; then
      DESKTOP=$(${pkgs.xdg-utils}/bin/xdg-mime query default x-scheme-handler/mailto 2>/dev/null)
    else
      MIME=$(${pkgs.xdg-utils}/bin/xdg-mime query filetype "$URL" 2>/dev/null)
      if [ -n "$MIME" ]; then
        DESKTOP=$(${pkgs.xdg-utils}/bin/xdg-mime query default "$MIME" 2>/dev/null)
      fi
    fi

    # Trouver le fichier .desktop complet et en extraire la commande Exec
    EXEC_CMD=""
    if [ -n "$DESKTOP" ]; then
      for dir in "$HOME/.local/share/applications" "/etc/profiles/per-user/$USER/share/applications" "/run/current-system/sw/share/applications"; do
        if [ -f "$dir/$DESKTOP" ]; then
          EXEC_CMD=$(grep -m1 "^Exec=" "$dir/$DESKTOP" | sed 's/^Exec=//' | sed 's/ %.*//' | xargs basename 2>/dev/null)
          break
        fi
      done
    fi

    # Lancer le VRAI xdg-open par son chemin complet Nix (évite la récursion)
    ${pkgs.xdg-utils}/bin/xdg-open "$@" &

    # Attendre que l'app traite la requête puis forcer le focus via niri
    sleep 0.5
    if [ -n "$EXEC_CMD" ]; then
      # Chercher la fenêtre Niri dont le processus correspond à la commande Exec
      WINDOW_ID=$(niri msg --json windows 2>/dev/null \
        | ${pkgs.jq}/bin/jq -r --arg cmd "$EXEC_CMD" \
          '[.[] | select(.app_id | test($cmd; "i"))][0].id // empty')

      # Fallback : chercher par PID du processus
      if [ -z "$WINDOW_ID" ]; then
        TARGET_PID=$(pgrep -x "$EXEC_CMD" 2>/dev/null | head -1)
        if [ -n "$TARGET_PID" ]; then
          WINDOW_ID=$(niri msg --json windows 2>/dev/null \
            | ${pkgs.jq}/bin/jq -r --argjson pid "$TARGET_PID" \
              '[.[] | select(.pid == $pid)][0].id // empty')
        fi
      fi

      if [ -n "$WINDOW_ID" ]; then
        niri msg action focus-window --id "$WINDOW_ID"
      fi
    fi
  '';
in
{
  imports = [
    ./binds.nix
    ./style.nix
  ];

  # Installer le wrapper xdg-open + jq comme dépendance
  home.packages = [
    xdg-open-with-focus
    pkgs.jq
  ];

  programs.niri.settings = {

    # deactivate niri hotkey pannel at startup
    hotkey-overlay.skip-at-startup = true;

    input.keyboard.xkb = {
      layout = "us";
      model = "pc104";
      variant = "intl";
    };

    prefer-no-csd = true;

    spawn-at-startup = [
      # { command = [ "sleep 15; systemctl --user restart swaybg" ]; }
      { command = [ "xwayland-satellite" ]; }
    ];

    debug = {
      # Permet le focus même si le token d'activation est "imparfait" (ex: via une notification)
      honor-xdg-activation-with-invalid-serial = true;
      # Corrige les soucis de focus pour les apps Chromium/Electron
      deactivate-unfocused-windows = true;
    };

    environment."DISPLAY" = ":0";

    layout.default-column-width = {
      proportion = 1. / 2.;
    };

    layout.preset-column-widths = [
      { proportion = 1. / 3.; }
      { proportion = 1. / 2.; }
      { proportion = 2. / 3.; }
    ];

    layout.preset-window-heights = [
      { proportion = 1.; }
      { proportion = 1. / 3.; }
      { proportion = 1. / 2.; }
      { proportion = 2. / 3.; }
    ];

    # Configuration des écrans
    # DP-2 (2K) à gauche, HDMI-A-1 (4K) à droite
    outputs = {
      "DP-2" = {
        # Écran 2K AOC (à gauche, avec 75Hz)
        mode = {
          width = 2560;
          height = 1440;
          refresh = 74.968;
        };
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
      };
      "HDMI-A-1" = {
        # Écran 4K LG (à droite)
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.0;
        };
        scale = 2.0; # Scale 2x pour 4K
        position = {
          x = 2560; # Juste après le 2K
          y = 0;
        };
      };
    };

  };
}
