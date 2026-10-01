{den, ...}: {
  den.aspects.nh.nixos = {
    pkgs,
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
    home-manager.users.${username}.programs.fish.functions = {
      nos = "nh os switch ${settings.configDirectory} --hostname ${settings.hostname} --ask -L --diff always";

      # Pre-builds the system after every save so that `nos` only has to
      # activate: evaluation (~14 s) and builds are done while you work. Builds
      # only, never activates. Restarts if you save again mid-build; Ctrl+C stops it.
      nosw = ''
        echo "nosw: pré-build à chaque sauvegarde dans ${settings.configDirectory} (Ctrl+C pour arrêter)"
        nice -n 19 ${pkgs.watchexec}/bin/watchexec \
          --watch ${settings.configDirectory} \
          --debounce 5s \
          --restart \
          -- nh os build ${settings.configDirectory} --hostname ${settings.hostname} --no-nom -o "$XDG_RUNTIME_DIR/nosw-result"
      '';
    };
  };
}
