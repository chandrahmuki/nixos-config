{ config, lib, pkgs, username, inputs, ... }:

{
  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  home-manager.users.${username} = { config, lib, pkgs, ... }:
    let
      colors = (import ../lib/colors.nix).tokyonight;
    in
    {
      xdg.mimeApps.defaultApplications = {
        "text/html" = "zen-browser.desktop";
        "x-scheme-handler/http" = "zen-browser.desktop";
        "x-scheme-handler/https" = "zen-browser.desktop";
        "x-scheme-handler/about" = "zen-browser.desktop";
        "x-scheme-handler/webcal" = "zen-browser.desktop";
      };
    };
}