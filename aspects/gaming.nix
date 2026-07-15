{den, ...}: {
  den.aspects.gaming.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
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
      gpu-screen-recorder.enable = true;
    };
    services.lact.enable = true;
    boot.kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];
  };

  den.aspects.muggy-nixos.includes = [den.aspects.gaming];
}
