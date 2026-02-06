# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/font.nix
    ../../modules/steam.nix
    ../../modules/lact.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Keep only 5 generations in boot menu
  boot.loader.efi.canTouchEfiVariables = true;

  # Automatic garbage collection (weekly, keep 5 days of builds)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  #AMD
  boot.initrd.kernelModules = [ "amdgpu" ];

  #Manage backup for config in home manager
  home-manager.backupFileExtension = "backup";

  #Steam and games
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  #Activate KornFlakes
  nix.settings.experimental-features = [
    "nix-command"
    "nix-command"
    "flakes"
  ];

  # Use latest kernel via Chaotic Nyx definition below
  # boot.kernelPackages = pkgs.linuxPackages_latest; # Removed to favor CachyOS kernel

  networking.hostName = "muggy-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GDM Customization (HiDPI scaling)
  programs.dconf.profiles.gdm.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          scaling-factor = lib.gvariant.mkUint32 2; # 2x scale for HiDPI
          text-scaling-factor = 1.25; # Slightly larger text
        };
        "org/gnome/login-screen" = {
          banner-message-enable = false;
          disable-user-list = false; # Show user list
        };
      };
    }
  ];

  # Make GDM monitor configuration permanent
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - /home/david/.config/monitors.xml"
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #default to fish !
  programs.fish.enable = true;
  # Indispensable pour les binaires
  programs.nix-ld.enable = true;

  # Empêche les jeux de "s'endormir" ou de tomber en FPS quand le workspace change
  environment.sessionVariables = {
    SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
    vk_xwayland_wait_ready = "false";
    MESA_SHADER_CACHE_MAX_SIZE = "16G";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.david = {
    isNormalUser = true;
    description = "David";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    shell = pkgs.fish;

    packages = with pkgs; [
      #  thunderbird
    ];
  };
  # niri setup using unstable
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # XDG Desktop Portal is handled by Sodiboo's Niri module
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

  # Polkit for niri using the gnome one.
  security.polkit.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    xwayland-satellite
    nvtopPackages.amd
  ];

  # --- OPTIMIZATIONS ---

  # 1. Memory Management (ZRAM)
  zramSwap.enable = true;

  # 2. SSD Maintenance (Trim)
  services.fstrim.enable = true;

  # 3. Store Optimization (Deduplication)
  nix.settings.auto-optimise-store = true;

  # 4. Gaming & GPU
  programs.gamemode.enable = true;

  # 5. Kernel Scheduler (SCX - CachyOS-like)
  services.scx = {
    enable = true;
    scheduler = "scx_lavd"; # Retour vers LAVD, plus stable pour les transitions de focus
  };

  # 7. Advanced: CachyOS Latest Kernel via xddxdd
  nix.settings = {
    substituters = [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos.packages.x86_64-linux.linux-cachyos-bore;

  # 8. Advanced: Build in RAM (tmpfs) - 62GB RAM required
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "75%"; # Use up to 75% of RAM for build

  # 9. Advanced: TCP Optimizations (Standard stable)
  # On repasse sur fq_codel/cubic car CAKE/BBR demandent trop de CPU pendant les downloads Steam sur HDD
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "cubic";
  };
  boot.kernelParams = [ "amdgpu.gttsize=16384" ];
  boot.kernelModules = [ "ntsync" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
