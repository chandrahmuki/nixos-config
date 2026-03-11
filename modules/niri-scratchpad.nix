{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.niri-scratchpad.packages.${pkgs.system}.default
    pkgs.heynote
  ];
}
