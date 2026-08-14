{den, ...}: {
  den.aspects.handbrake.nixos = {
    pkgs,
    inputs,
    username,
    ...
  }: let
    pkgs-master = import inputs.nixpkgs-master {
      system = pkgs.stdenv.hostPlatform.system;
      config = pkgs.config;
    };
  in {
    home-manager.users.${username} = {
      home.packages = [pkgs-master.handbrake];
    };
  };

}
