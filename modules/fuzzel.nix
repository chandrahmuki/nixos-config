{ pkgs, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme # Fallback for apps missing in Papirus
    hicolor-icon-theme # Base icon theme (fallback)
  ];

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font:size=18";
        terminal = "${pkgs.ghostty}/bin/ghostty";
        prompt = "'❯ '";
        layer = "overlay";
        icons-enabled = "yes";
        icon-theme = "Papirus-Dark";
        width = 40;
        lines = 15;
      };

      colors = {
        background = "282a36ff"; # Dracula Background
        text = "f8f8f2ff"; # Dracula Foreground
        match = "8be9fdff"; # Dracula Cyan (for matches)
        selection = "44475aff"; # Dracula Selection
        selection-text = "ffffffff";
        border = "bd93f9ff"; # Dracula Purple
      };

      border = {
        width = 2;
        radius = 10;
      };
    };
  };

  # Symlinks pour les icônes manquantes dans les thèmes standards
  home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source =
    "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

  # Pour Antigravity, on essaie de pointer vers son icône si elle est packagée
  # Note: Si l'icône n'est pas trouvée, HM ignorera ou on ajustera.
  home.file.".local/share/icons/hicolor/scalable/apps/antigravity.svg".source = "${
    pkgs.antigravity-unwrapped or pkgs.antigravity
  }/share/icons/hicolor/scalable/apps/antigravity.svg";
}
