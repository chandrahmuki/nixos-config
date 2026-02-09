{ pkgs, ... }:

{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--unlimited-storage"
      # Force le mode sombre pour l'UI du navigateur et le contenu des pages web
      "--enable-features=UseOzonePlatform,WebContentsForceDark"
      "--ozone-platform=wayland" # Force l'utilisation native de Wayland
      "--force-dark-mode"
    ];
  };

  # Écrase complètement com.brave.Browser.desktop pour qu'il soit caché
  home.file.".local/share/applications/com.brave.Browser.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Brave Browser (Hidden)
    NoDisplay=true
    Hidden=true
  '';
}
