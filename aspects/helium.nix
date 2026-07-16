{
  den,
  inputs,
  ...
}: {
  den.aspects.helium.homeManager = {
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
    xdg.desktopEntries.teams = {
      name = "Microsoft Teams";
      exec = "helium --app=https://teams.cloud.microsoft/";
      icon = "chrome-ompifgpmddkgmclendfeacglnodjjndh-Default";
      terminal = false;
      categories = ["Network" "InstantMessaging" "Chat"];
      settings.StartupWMClass = "crx_ompifgpmddkgmclendfeacglnodjjndh";
    };
  };

  den.aspects.muggy-nixos.nixos.environment.etc."chromium/policies/managed/helium.json".text = builtins.toJSON {
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
    WebAppInstallForceList = [
      {
        url = "https://teams.cloud.microsoft/";
        default_launch_container = "window";
        create_desktop_shortcut = true;
      }
    ];
  };

  den.aspects.david.includes = [den.aspects.helium];
}
