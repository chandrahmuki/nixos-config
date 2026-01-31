{ pkgs, ... }:

{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--unlimited-storage"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
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
