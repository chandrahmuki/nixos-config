{ inputs, pkgs, ... }:
{
  programs.niri.settings = {
    layout = {
      gaps = 16;
      focus-ring.width = 6;
      focus-ring.active.color = "rgba(255,255,255,0.3)";
      focus-ring.inactive.color = "rgba(100,100,100,0.3)";
    };

    window-rules = [
      {
        matches = [ { app-id = "brave-browser"; } ];
        open-focused = true;
      }
      {
        geometry-corner-radius = {
          bottom-left = 12.0;
          bottom-right = 12.0;
          top-left = 12.0;
          top-right = 12.0;
        };
        clip-to-geometry = true;
      }
    ];

  };
}
