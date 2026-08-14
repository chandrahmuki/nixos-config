{den, ...}: {
  den.aspects.notifications.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.libnotify];
  };

}
