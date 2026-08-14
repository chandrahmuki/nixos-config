{den, ...}: {
  den.aspects.microfetch.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.microfetch];
  };

}
