{den, ...}: {
  den.aspects.yazi.homeManager.programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "modified";
        sort_dir_first = true;
      };
      opener.listen = [
        {
          run = ''mpv --audio-display=no --no-video "$@"'';
          block = true;
          desc = "Listen";
        }
      ];
      open.prepend_rules = [
        {
          mime = "audio/*";
          use = "listen";
        }
        {
          url = "*.m3u";
          use = "listen";
        }
      ];
    };
  };

  den.aspects.david.includes = [den.aspects.yazi];
}
