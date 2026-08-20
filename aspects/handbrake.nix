{den, ...}: {
  den.aspects.handbrake.nixos = {
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      home.packages = [pkgs.pkgs-master.handbrake];
    };
  };

}
