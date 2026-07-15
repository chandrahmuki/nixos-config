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

  den.aspects.david.includes = [den.aspects.helium];
}
