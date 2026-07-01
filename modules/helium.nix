{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}: {
  home-manager.users.${username} = {pkgs, ...}: {
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
  };
}
