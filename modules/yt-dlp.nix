{ pkgs, inputs, ... }:

{
  programs.yt-dlp = {
    enable = true;
    package = inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.yt-dlp;
    settings = {
      embed-thumbnail = true;
      add-metadata = true;
      restrict-filenames = true;
      windows-filenames = true;
      output = "%(title)s.%(ext)s";
    };
  };

  programs.fish.functions = {
    yt = "yt-dlp -x --audio-format m4a $argv";
  };
}
