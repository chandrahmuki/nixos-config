{den, ...}: {
  den.aspects.discord.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      vesktop
      discordo
    ];
  };

  den.aspects.david.includes = [den.aspects.discord];
}
