{ ... }:

{
  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-thumbnail = true;
      add-metadata = true;
      restrict-filenames = true;
      windows-filenames = true;
      output = "%(title)s.%(ext)s";
    };
  };

  programs.fish.functions = {
    # Télécharge et extrait l'audio directement dans ~/Music
    # Les fichiers seront ainsi visibles dans le menu Walker
    yt = "yt-dlp -x --audio-format m4a -o '~/Music/%(title)s.%(ext)s' $argv";
  };
}
