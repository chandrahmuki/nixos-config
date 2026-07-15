{den, ...}: {
  den.aspects.direnv.homeManager.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };

  den.aspects.david.includes = [den.aspects.direnv];
}
