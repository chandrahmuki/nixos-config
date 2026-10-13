{den, ...}: {
  den.aspects.font.nixos = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      cozette
      # Only the Pixelify Sans family of the Google Fonts collection (80 KB), used by the Quickshell pill.
      (google-fonts.override {fonts = ["PixelifySans"];})
      noto-fonts
      dejavu_fonts
      noto-fonts-color-emoji
      font-awesome
    ];
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font"];
        sansSerif = ["DejaVu Sans"];
        serif = ["DejaVu Serif"];
      };
    };
  };
}
