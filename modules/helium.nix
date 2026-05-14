{ config, lib, pkgs, username, inputs, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = [
      inputs.helium.packages.${pkgs.system}.helium
    ];

    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "helium.desktop" ];
      "text/xml" = [ "helium.desktop" ];
      "application/xhtml+xml" = [ "helium.desktop" ];
      "x-scheme-handler/http" = [ "helium.desktop" ];
      "x-scheme-handler/https" = [ "helium.desktop" ];
    };
  };
}
