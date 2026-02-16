{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme # Fallback for apps missing in Papirus
    hicolor-icon-theme # Base icon theme (fallback)
  ];

  programs.fuzzel = {
    enable = true;
    # La configuration est gérée dynamiquement par sync-colors.py via un lien symbolique
  };

  # Symlinks pour les icônes manquantes dans les thèmes standards
  home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source =
    "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

  # Pour Antigravity, on essaie de pointer vers son icône si elle est packagée
  # Note: Si l'icône n'est pas trouvée, HM ignorera ou on ajustera.
  home.file.".local/share/icons/hicolor/scalable/apps/antigravity.svg".source = "${
    pkgs.antigravity-unwrapped or pkgs.antigravity
  }/share/icons/hicolor/scalable/apps/antigravity.svg";
  # Lien vers la config générée dynamiquement
  home.file.".config/fuzzel/fuzzel.ini".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/generated/fuzzel";
}
