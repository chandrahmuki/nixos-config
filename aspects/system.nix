{den, ...}: {
  den.aspects.desktop.nixos = {
    pkgs,
    inputs,
    lib,
    settings,
    username,
    hostname,
    ...
  }: {
    home-manager.backupFileExtension = "backup";

    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.kernelModules = ["amdgpu"];
    boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.linux-cachyos-bore;
    boot.tmp = {
      useTmpfs = true;
      tmpfsSize = "75%";
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    hardware.i2c.enable = true;

    services.xserver = {
      enable = true;
      videoDrivers = ["amdgpu"];
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    services.printing.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    services.udev.packages = [pkgs.via];
    services.fstrim.enable = true;
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    security.rtkit.enable = true;
    security.polkit.enable = true;

    nix = {
      gc.automatic = false;
      optimise.automatic = true;
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        fallback = true;
        substituters = [
          "https://nix-community.cachix.org"
          "https://attic.xuyh0120.win/lantian"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };

    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-40.10.5"
        "pnpm-10.29.2"
      ];
    };

    networking = {
      hostName = lib.mkForce hostname;
      networkmanager.enable = true;
    };
    time.timeZone = settings.timeZone;
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = settings.locale;
        LC_IDENTIFICATION = settings.locale;
        LC_MEASUREMENT = settings.locale;
        LC_MONETARY = settings.locale;
        LC_NAME = settings.locale;
        LC_NUMERIC = settings.locale;
        LC_PAPER = settings.locale;
        LC_TELEPHONE = settings.locale;
        LC_TIME = settings.locale;
      };
    };

    programs.fish.enable = true;
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse3
        icu
        nss
        openssl
        curl
        expat
        libx11
        libxscrnsaver
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb
        libxshmfence
        libxkbfile
      ];
    };

    environment = {
      sessionVariables = {
        vk_xwayland_wait_ready = "false";
        MESA_SHADER_CACHE_MAX_SIZE = "16G";
      };
      systemPackages = with pkgs; [
        bubblewrap
        ffmpeg
        socat
        libva-utils
        nvtopPackages.amd
        via
        nvd
      ];
    };

    users.users.${username} = {
      isNormalUser = true;
      description = username;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "input"
        "i2c"
      ];
      shell = pkgs.fish;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    zramSwap.enable = true;
  };
}
