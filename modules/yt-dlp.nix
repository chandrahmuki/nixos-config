{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    programs.yt-dlp = {
          enable = true;
          settings = {
            embed-thumbnail = true;
            add-metadata = true;
            restrict-filenames = true; # Force des noms de fichiers propres (sans quotes/espaces bizarres)
            windows-filenames = true;
            output = "%(title)s.%(ext)s";
          };
        };

        programs.fish.functions = {
          # Télécharge et extrait l'audio dans le répertoire COURANT (sans quotes forcées)
          yt = "yt-dlp -x --audio-format m4a $argv";
        };
  };
}
