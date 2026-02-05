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
            run = ''mpv --no-video "$@"'';
            desc = "Play Audio";
          }
        ];
      };
      open = {
        rules = [
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
