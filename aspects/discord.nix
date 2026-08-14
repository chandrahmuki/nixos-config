{den, ...}: {
  den.aspects.discord.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      vesktop
      discordo
    ];
  };

}
