{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "modified";
        sort_dir_first = true;
      };
      opener = {
        audio = [
          {
            run = ''mpv --audio-display=no --no-video "$@"'';
            block = true;
            desc = "Play Audio";
          }
        ];
      };
      open = {
        prepend_rules = [
          {
            name = "*.m4a";
            use = "audio";
          }
          {
            name = "*.mp3";
            use = "audio";
          }
          {
            name = "*.flac";
            use = "audio";
          }
          {
            name = "*.wav";
            use = "audio";
          }
        ];
      };
    };
  };
}
