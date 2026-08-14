{den, ...}: {
  den.aspects.nh.nixos = {
    username,
    settings,
    ...
  }: {
    programs.nh = {
      enable = true;
      flake = settings.configDirectory;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
    home-manager.users.${username}.programs.fish.functions.nos = "nh os switch ${settings.configDirectory} --hostname ${settings.hostname} --ask -L --diff always";
  };

}
