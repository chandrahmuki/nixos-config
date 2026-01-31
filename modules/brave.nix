{ pkgs, config, ... }:

{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--unlimited-storage"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  # Cache l'icône par défaut du système
  home.file.".local/share/applications/brave-browser.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Brave Web Browser
    Exec=${config.programs.brave.package}/bin/brave %U --enable-features=UseOzonePlatform --ozone-platform=wayland --unlimited-storage
    Icon=brave-browser
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
    StartupWMClass=brave-browser
    StartupNotify=true
  '';
}
