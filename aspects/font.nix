{den, ...}: {
  den.aspects.font.nixos = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
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

  den.aspects.muggy-nixos.includes = [den.aspects.font];
}
