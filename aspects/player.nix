{den, ...}: {
  den.aspects.player.homeManager = {
    config,
    pkgs,
    ...
  }: let
    playerLua = pkgs.writeText "player.lua" (builtins.replaceStrings ["@notify@"] ["${pkgs.libnotify}/bin/notify-send"] (builtins.readFile ../files/player/player.lua));
    # The look of the player: one JSON file per theme (files/player/themes/README.md).
    playerThemes = builtins.path {
      path = ../files/player/themes;
      name = "player-themes";
    };
    # Radio stations for the R key; yours go in ~/.config/player/radios.json.
    playerRadios = ../files/player/radios.json;
    player = pkgs.writeShellScriptBin "player" (builtins.replaceStrings ["@mpv@" "@script@" "@socat@" "@cava@" "@awk@" "@themes@" "@jq@" "@radios@"] ["${config.programs.mpv.finalPackage}/bin/mpv" "${playerLua}" "${pkgs.socat}/bin/socat" "${pkgs.cava}/bin/cava" "${pkgs.gawk}/bin/awk" "${playerThemes}" "${pkgs.jq}/bin/jq" "${playerRadios}"] (builtins.readFile ../files/player/player.sh));
  in {
    home.packages = [player];
  };
}
