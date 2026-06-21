{
  config,
  lib,
  pkgs,
  ...
}: {
  services.desktopManager.plasma6.enable = true;
  services.input-remapper.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    gwenview
    okular
    kate
    khelpcenter
    konsole
    krdc
    plasma-welcome
  ];

  environment.systemPackages = with pkgs; [
    nordic
    nordzy-icon-theme
    nordzy-cursor-theme
    utterly-nord-plasma
  ];
}

