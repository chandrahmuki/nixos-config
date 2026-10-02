# The generic host: the public settings on a minimal hardware configuration.
{
  settings = import ../../settings.nix;
  hardwareModule = ./hardware-configuration.nix;
}
