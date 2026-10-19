{den, ...}: {
  den.aspects.nh.nixos = {
    pkgs,
    username,
    settings,
    ...
  }: let
    # The NAS builds its own configuration: `nixos-rebuild --target-host` from here fails
    # ("lacks a signature by a trusted key"), the admin is not a trusted user of its store
    # on purpose (hosts/nas/README.md). So: copy the repository over, build there.
    nasCopy = ''
      ${pkgs.rsync}/bin/rsync -a --delete --exclude=.git --exclude=result --exclude=.claude \
        ${settings.configDirectory}/ ${username}@nas:nixos-config/
    '';
    musicTagCheck = pkgs.writeShellScript "music-tag-check" ''
      music=/home/${username}/Music
      ${pkgs.rsync}/bin/rsync -an --ignore-existing --out-format=%n "$music/" ${username}@nas:/data/media/music/ \
        | grep -iE '\.(m4a|mp3|opus|flac|ogg|webm)$' | while IFS= read -r f; do
        tags=$(${pkgs.ffmpeg}/bin/ffprobe -v error -show_entries format_tags=album,artist,title \
          -of default=nw=1:nk=0 "$music/$f" 2>/dev/null)
        missing=""
        for t in album artist title; do
          grep -qiE "^TAG:$t=." <<<"$tags" || missing="$missing $t"
        done
        [ -z "$missing" ] || echo "sans tag ($missing ) : $f"
      done
      true
    '';
    nasPrebuild = pkgs.writeShellScript "nas-prebuild" ''
      set -e
      ${nasCopy}
      ${pkgs.openssh}/bin/ssh ${username}@nas 'nixos-rebuild build --flake path:$HOME/nixos-config#nas'
    '';
  in {
    programs.nh = {
      enable = true;
      flake = settings.configDirectory;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
    # PATH (including /run/wrappers/bin for sudo) is already ensured by
    # fish_add_path in aspects/terminal.nix, no need to repeat it here.
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

      # The NAS version of `nos`: copies the repository over and switches the NAS (asks
      # for the sudo password of the NAS).
      nasos = ''
        ${nasCopy}
        and ssh -t ${username}@nas 'sudo nixos-rebuild switch --flake path:$HOME/nixos-config#nas'
      '';

      # The NAS version of `nosw`: builds the NAS configuration on the NAS after every save
      # in hosts/nas, never activates, so `nasos` only has to switch.
      nasw = ''
        echo "nasw: pré-build du NAS à chaque sauvegarde dans ${settings.configDirectory}/hosts/nas (Ctrl+C pour arrêter)"
        nice -n 19 ${pkgs.watchexec}/bin/watchexec \
          --watch ${settings.configDirectory}/hosts/nas \
          --debounce 5s \
          --restart \
          -- ${nasPrebuild}
      '';

      # Sends the new music of ~/Music to the NAS: only files that are not there yet, nothing
      # overwritten or deleted. Navidrome's watcher notices them and scans by itself.
      # Before sending, it lists the new files without an album, artist or title tag:
      # Navidrome files those under "Unknown Album" / "Unknown Artist".
      musync = ''
        ${musicTagCheck}
        and ${pkgs.rsync}/bin/rsync -a --ignore-existing --info=NAME,STATS1 \
          /home/${username}/Music/ ${username}@nas:/data/media/music/
      '';
    };
  };
}
