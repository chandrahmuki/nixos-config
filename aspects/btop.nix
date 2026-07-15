{den, ...}: {
  den.aspects.btop.homeManager.programs.btop = {
    enable = true;
    settings.vim_keys = true;
  };

  den.aspects.david.includes = [den.aspects.btop];
}
