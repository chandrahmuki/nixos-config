{ inputs, pkgs, ... }:
{
  programs.niri.settings = {
    layout = {
      gaps = 32;
      focus-ring.width = 6;
      focus-ring.active.color = "rgba(255,255,255,0.3)";
      focus-ring.inactive.color = "rgba(100,100,100,0.3)";
    };

  };
}
