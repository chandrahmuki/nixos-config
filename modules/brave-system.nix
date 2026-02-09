{ ... }:

{
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
}
