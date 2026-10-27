{den, ...}: {
  den.aspects.gaming.nixos = {pkgs, ...}: let
    # Epic's own Linux launcher (preview), published as an AppImage only.
    epic-games-launcher = let
      pname = "epic-games-launcher";
      version = "0.103.0";
      src = pkgs.fetchurl {
        url = "https://content-download-egs.distro.on.epicgames.com/Builds/EGLv2/0.103.0%2Bg66c2498/Linux/EpicGamesLauncher-x86_64.AppImage";
        hash = "sha256-bizh9dUNFmeOtZrfCer/ueko+uRKO9rpsQ2BDeJJV1s=";
      };
      contents = pkgs.appimageTools.extract {inherit pname version src;};
    in
      pkgs.appimageTools.wrapType2 {
        inherit pname version src;
        # Wine's bcrypt/secur32/crypt32 load libgnutls for TLS and ECDSA checks;
        # neither the AppImage nor GE-Proton ships it (MTGA: TrustFailure).
        extraPkgs = pkgs: [pkgs.gnutls];
        extraInstallCommands = ''
          install -Dm444 ${contents}/EpicGamesLauncher.png \
            $out/share/icons/hicolor/512x512/apps/EpicGamesLauncher.png
          install -Dm444 ${contents}/epic-games-launcher.desktop \
            $out/share/applications/epic-games-launcher.desktop
          substituteInPlace $out/share/applications/epic-games-launcher.desktop \
            --replace-fail "Exec=EpicGamesLauncher" "Exec=$out/bin/epic-games-launcher"
        '';
      };
  in {
    environment.systemPackages = with pkgs; [
      epic-games-launcher
      mangohud
      protonup-qt
      lutris
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
