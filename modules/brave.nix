{ config, lib, pkgs, username, ... }:

{
  # --- PARTIE SYSTÈME (NixOS) ---
  # On utilise le module Chromium système pour forcer les politiques dans Brave
  programs.chromium = {
    enable = true;
    extraOpts = {
      "ExtensionInstallForcelist" = [
        "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # Bitwarden
        "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx" # uBlock Origin
        "dcbfghmdnnkkkjjpmghnoaidojfickmj;https://clients2.google.com/service/update2/crx" # Theme: Thassos Sea View
      ];
      "WebAppInstallForceList" = [
        {
          url = "https://teams.microsoft.com/";
          default_launch_container = "window";
          create_desktop_shortcut = true;
        }
      ];
    };
  };

  # --- PARTIE UTILISATEUR (Home Manager) ---
  home-manager.users.${username} = { config, lib, ... }: {
    programs.brave = {
      enable = true;
      commandLineArgs = [
        "--unlimited-storage"
        "--enable-features=UseOzonePlatform,WebContentsForceDark"
        "--ozone-platform=wayland"
        "--force-dark-mode"
      ];
    };

    home.file.".local/share/applications/com.brave.Browser.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Brave Browser
      Exec=brave %U
      Terminal=false
      NoDisplay=true
      Categories=Network;WebBrowser;
      MimeType=text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
    '';
  };
}
