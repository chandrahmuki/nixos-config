{ pkgs, ... }:

let
  # Script wrapper qui ouvre une URL dans Brave puis force le focus via niri
  # Fonctionne sur tous les moniteurs et workspaces grâce à niri msg
  brave-open-focused = pkgs.writeShellScriptBin "brave-open-focused" ''
    # Ouvrir l'URL dans Brave (nouvel onglet si déjà lancé)
    brave "$@" &

    # Attendre un court instant que Brave traite la requête
    sleep 0.3

    # Trouver l'ID de la première fenêtre Brave et forcer le focus
    WINDOW_ID=$(${pkgs.niri-unstable}/bin/niri msg --json windows 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '[.[] | select(.app_id == "brave-browser")][0].id // empty')

    if [ -n "$WINDOW_ID" ]; then
      ${pkgs.niri-unstable}/bin/niri msg action focus-window --id "$WINDOW_ID"
    fi
  '';
in
{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--unlimited-storage"
      # Force le mode sombre pour l'UI du navigateur et le contenu des pages web
      "--enable-features=UseOzonePlatform,WebContentsForceDark"
      "--ozone-platform=wayland" # Force l'utilisation native de Wayland
      "--force-dark-mode"
    ];
  };

  # Rendre le script disponible dans le PATH
  home.packages = [ brave-open-focused ];

  # Desktop entry caché mais valide, utilisant le wrapper pour le focus automatique
  home.file.".local/share/applications/com.brave.Browser.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Brave Browser
    Exec=brave-open-focused %U
    Terminal=false
    NoDisplay=true
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
  '';
}
