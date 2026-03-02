{ pkgs, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = true; # Dark mode by default
      recolor-keephue = true;
      
      # Premium Dark Theme (Catppuccin-like)
      default-bg = "#1e1e2e";
      default-fg = "#cdd6f4";
      statusbar-bg = "#181825";
      statusbar-fg = "#cdd6f4";
      inputbar-bg = "#11111b";
      inputbar-fg = "#cdd6f4";
      recolor-lightcolor = "#1e1e2e";
      recolor-darkcolor = "#cdd6f4";
    };
  };
}
