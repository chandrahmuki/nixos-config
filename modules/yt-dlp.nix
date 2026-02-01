{ _pkgs, ... }:

{
  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-thumbnail = true;
      add-metadata = true;
    };
  };

  programs.fish.functions = {
    yt = "yt-dlp -x --audio-format m4a $argv";
  };
}
