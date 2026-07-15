{den, ...}: {
  den.aspects.microfetch.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.microfetch];
  };

  den.aspects.david.includes = [den.aspects.microfetch];
}
