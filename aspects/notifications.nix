{den, ...}: {
  den.aspects.notifications.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.libnotify];
  };

  den.aspects.david.includes = [den.aspects.notifications];
}
