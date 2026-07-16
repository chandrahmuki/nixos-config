{den, ...}: {
  den.aspects.muggy-nixos.nixos = {
    config,
    pkgs,
    inputs,
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
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [
        "/"
        "/mnt/storage"
        "/mnt/games"
        "/mnt/backup"
      ];
    };
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
        warn-dirty = false;
        substituters = [
          "https://nix-community.cachix.org"
          "https://attic.xuyh0120.win/lantian"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2pYERgpwg2r3XJZ5KKqjp5xrdsusarMU="
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
      permittedInsecurePackages = ["pnpm-10.29.2"];
    };

    networking = {
      hostName = hostname;
      networkmanager.enable = true;
    };
    time.timeZone = "Europe/Vienna";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "de_AT.UTF-8";
        LC_IDENTIFICATION = "de_AT.UTF-8";
        LC_MEASUREMENT = "de_AT.UTF-8";
        LC_MONETARY = "de_AT.UTF-8";
        LC_NAME = "de_AT.UTF-8";
        LC_NUMERIC = "de_AT.UTF-8";
        LC_PAPER = "de_AT.UTF-8";
        LC_TELEPHONE = "de_AT.UTF-8";
        LC_TIME = "de_AT.UTF-8";
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
        xwayland-satellite-unstable
        ffmpeg
        mpvpaper
        socat
        libva-utils
        nvtopPackages.amd
        via
        nvd
        inputs.omnigraph.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      etc."chromium/policies/managed/helium.json".text = builtins.toJSON {
        BrowserSignin = 0;
        PasswordManagerEnabled = false;
        CredentialsEnableService = false;
        SyncDisabled = true;
        DefaultBrowserSettingEnabled = false;
        MetricsReportingEnabled = false;
        BackgroundModeEnabled = false;
        ChromeCleanupEnabled = false;
        ChromeCleanupReportingEnabled = false;
        CookiesAllowedForUrls = [
          "[*.]microsoft.com"
          "[*.]microsoftonline.com"
          "[*.]live.com"
          "[*.]teams.microsoft.com"
          "[*.]skype.com"
          "[*.]cloud.microsoft"
          "[*.]teams.cloud.microsoft"
        ];
        WebAppInstallForceList = [
          {
            url = "https://teams.cloud.microsoft/";
            default_launch_container = "window";
            create_desktop_shortcut = true;
          }
        ];
      };
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
      config.niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    systemd.tmpfiles.rules = [
      "d /mnt/games 0755 ${username} users -"
      "d /mnt/storage 0755 ${username} users -"
    ];
    zramSwap.enable = true;
  };

}
