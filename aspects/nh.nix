{den, ...}: {
  den.aspects.nh = {
    host,
    user,
    ...
  }: {
    nixos.programs.nh = {
      enable = true;
      flake = "/home/${user.userName}/nixos-config";
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
    homeManager.programs.fish.functions.nos = "nh os switch /home/${user.userName}/nixos-config --hostname ${host.hostName} --ask -L --diff always";
  };

  den.aspects.david.includes = [den.aspects.nh];
}
