{
  settings = import ./settings.nix;
  hardwareModule = ./hardware-configuration.nix;
  extraModules = [./extra.nix];
}
