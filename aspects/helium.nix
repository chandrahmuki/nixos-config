{
  den,
  inputs,
  ...
}: {
  den.aspects.helium.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    teamsIcon =
      pkgs.runCommand "teams-icon.png" {
        nativeBuildInputs = [pkgs.imagemagick];
        src = pkgs.fetchurl {
          url = "https://teams.public.onecdn.static.microsoft/evergreen-assets/icons/microsoft_teams_logo_refresh_v2025.ico";
          hash = "sha256-W0exIwj4emqAYPY9yRyi/QGwY+PSM6pi9ewlXNaOYDc=";
        };
      } ''
        magick "$src[0]" PNG32:$out
      '';
    xIcon = pkgs.fetchurl {
      url = "https://x.com/apple-touch-icon.png";
      hash = "sha256-qDVC6wVjJClJ19vecgAU+3q0iuFO1Z9D7sNJB8uQxHc=";
    };
  in {
    imports = [inputs.helium.homeModules.default];
    programs.helium = {
      enable = true;
      flags = [
        "--ozone-platform-hint=auto"
        "--use-gl=egl"
        "--ignore-gpu-blocklist"
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,WaylandWindowDecorations,WebRTCPipeWireCapturer"
      ];
    };
    xdg.mimeApps.defaultApplications = {
      "text/html" = ["helium.desktop"];
      "text/xml" = ["helium.desktop"];
      "application/xhtml+xml" = ["helium.desktop"];
      "x-scheme-handler/http" = ["helium.desktop"];
      "x-scheme-handler/https" = ["helium.desktop"];
    };
    xdg.dataFile."applications/chrome-teams.cloud.microsoft__-Default.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Microsoft Teams
      Exec=helium --user-data-dir=${config.xdg.dataHome}/helium-teams --class=chrome-teams.cloud.microsoft_.Default --app=https://teams.cloud.microsoft/
      Icon=${teamsIcon}
      Terminal=false
      Categories=Network;InstantMessaging;Chat;
      StartupWMClass=chrome-teams.cloud.microsoft__-Default
    '';
    xdg.dataFile."icons/hicolor/256x256/apps/chrome-teams.cloud.microsoft_.Default.png".source = teamsIcon;
    xdg.dataFile."applications/chrome-x.com__-Default.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=X
      Exec=helium --user-data-dir=${config.xdg.dataHome}/helium-x --class=chrome-x.com_.Default --app=https://x.com/
      Icon=${xIcon}
      Terminal=false
      Categories=Network;Social;
      StartupWMClass=chrome-x.com__-Default
    '';
    xdg.dataFile."icons/hicolor/256x256/apps/chrome-x.com_.Default.png".source = xIcon;
    home.activation.removeLegacyTeamsLauncher = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -f ${config.xdg.dataHome}/applications/teams.desktop
      rm -f ${config.xdg.dataHome}/applications/chrome-ompifgpmddkgmclendfeacglnodjjndh-Default.desktop
      rm -f ${config.xdg.dataHome}/applications/chrome-teams.cloud.microsoft_.Default.desktop
    '';
  };

  den.aspects.desktop.nixos = {lib, ...}: {
    environment.etc."chromium/policies/managed/helium.json".text = builtins.toJSON {
      BrowserSignin = 0;
      PasswordManagerEnabled = false;
      CredentialsEnableService = false;
      SyncDisabled = true;
      DefaultBrowserSettingEnabled = false;
      MetricsReportingEnabled = false;
      BackgroundModeEnabled = false;
      ChromeCleanupEnabled = false;
      ChromeCleanupReportingEnabled = false;
      CookiesAllowedForUrls = [
        "[*.]microsoft.com"
        "[*.]microsoftonline.com"
        "[*.]live.com"
        "[*.]teams.microsoft.com"
        "[*.]skype.com"
        "[*.]cloud.microsoft"
        "[*.]teams.cloud.microsoft"
      ];
    };

    # Stylix's own "chromium" target (modules/chromium/nixos.nix upstream)
    # force-enables programs.chromium and writes a system-wide
    # BrowserThemeColor policy (Stylix's static base00 — muggy's green,
    # forever, since Stylix's scheme never changes at runtime) to every
    # Chromium-derivative's policy directory. That's the actual source of
    # the "stuck green, ask your administrator" lock on Helium's own theme
    # picker — nothing in this repo declared it. Force it off, same pattern
    # as stylix.targets.hyprpaper in aspects/hyprland.nix.
    stylix.targets.chromium.enable = lib.mkForce false;
  };
}
