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
    # PATH (dont /run/wrappers/bin pour sudo) est déjà garanti par
    # fish_add_path dans aspects/terminal.nix, pas besoin de le refaire ici.
    home-manager.users.${username}.programs.fish.functions.nos = "nh os switch ${settings.configDirectory} --hostname ${settings.hostname} --ask -L --diff always";
  };

}
