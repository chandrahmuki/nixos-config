{den, ...}: {
  den.aspects.gaming.nixos = {pkgs, ...}: let
    # Epic's own Linux launcher (preview), published as a Debian package.
    epic-games-launcher = let
      pname = "epic-games-launcher";
      version = "0.113.0";
    in
      pkgs.stdenvNoCC.mkDerivation {
        inherit pname version;
        src = pkgs.fetchurl {
          url = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher-x86_64.deb";
          hash = "sha256-iE3vjeJHvCeb6lcb5vXexsVIGslMwGr2K1d2JL5WwgE=";
        };
        nativeBuildInputs = [pkgs.dpkg];
        unpackPhase = "dpkg-deb -x $src .";
        installPhase = ''
          mkdir -p $out
          cp -r usr/* $out/
          mkdir -p $out/bin
          ln -s $out/bin/EpicGamesLauncher $out/bin/epic-games-launcher
          substituteInPlace $out/share/applications/epic-games-launcher.desktop \
            --replace-fail "Exec=EpicGamesLauncher" "Exec=$out/bin/epic-games-launcher"
        '';
      };
    pokopia-launcher = pkgs.writeShellScriptBin "pokopia-launcher" ''
      export LD_LIBRARY_PATH="${pkgs.libgpg-error}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec ${pkgs.appimage-run}/bin/appimage-run "$HOME/.local/share/pokopia-recomp/PokopiaLauncher.AppImage" "$@"
    '';
    dusklight-launcher = pkgs.writeShellScriptBin "dusklight-launcher" ''
      exec ${pkgs.appimage-run}/bin/appimage-run "$HOME/.local/share/dusklight/Dusklight.AppImage" "$@"
    '';
  in {
    environment.systemPackages = with pkgs; [
      epic-games-launcher
      pokopia-launcher
      dusklight-launcher
      mangohud
      protonup-qt
      lact
      eden
    ];
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession.enable = true;
      };
      gamescope.enable = true;
      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            renice = 10;
            softrealtime = "auto";
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            amd_performance_level = "high";
          };
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };
    };
    services.lact.enable = true;
    boot.kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];
  };
}
