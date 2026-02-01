{ pkgs, inputs, ... }:

{
  programs.yt-dlp = {
    enable = true;
    package = inputs.nixpkgs-master.legacyPackages.${pkgs.system}.yt-dlp;
    settings = {
      embed-thumbnail = true;
      add-metadata = true;
    };
  };

  programs.fish.functions = {
    yt = "yt-dlp -x --audio-format m4a $argv";
  };
}
