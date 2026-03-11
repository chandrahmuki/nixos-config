{ ... }:

{
  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-thumbnail = true;
      add-metadata = true;
      restrict-filenames = false; # On autorise les espaces
      windows-filenames = true;
      output = "%(title)s.%(ext)s";
    };
  };

  programs.fish.functions = {
    # Télécharge et extrait l'audio dans le répertoire COURANT
    yt = "yt-dlp -x --audio-format m4a -o '%(title)s.%(ext)s' $argv";
  };
}
