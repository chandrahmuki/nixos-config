# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  hostname,
  ...
}: {
  # Importation de la configuration matérielle et des modules système
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Extension de sauvegarde automatique des fichiers conflictuels avec Home Manager
  home-manager.backupFileExtension = "backup";

  # Configuration du chargeur de démarrage Systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Limiter à 5 générations conservées dans le menu boot
  boot.loader.efi.canTouchEfiVariables = true;

  # Nettoyage automatique des anciennes générations désactivé (géré par nh)
  nix.gc.automatic = false;

  # Pilotes et modules noyau chargés au démarrage pour le GPU AMD
  boot.initrd.kernelModules = ["amdgpu"];

  # Support de l'accélération graphique 3D (32 bits pour Steam et les jeux)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = ["amdgpu"];

  # Activation des fonctionnalités expérimentales de Nix (nix-command et flakes)
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Épinglage des canaux Nixpkgs pour la cohérence des commandes nix-shell système
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  # Configuration du nom d'hôte de la machine
  networking.hostName = hostname;

  # Configuration du réseau avec NetworkManager
  networking.networkmanager.enable = true;

  # Fuseau horaire du système
  time.timeZone = "Europe/Vienna";

  # Paramètres de langue et localisation (Autriche/Allemand par défaut)
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

  # Support du protocole d'affichage X11
  services.xserver.enable = true;

  # Configuration de la disposition du clavier X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Serveur d'impression CUPS
  services.printing.enable = true;

  # Configuration du son avec Pipewire (PulseAudio désactivé)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Activation du Shell Fish comme shell par défaut pour les utilisateurs
  programs.fish.enable = true;

  # Prise en charge de nix-ld pour exécuter des exécutables Linux pré-compilés
  programs.nix-ld = {
    enable = true;
    libraries = [
      pkgs.stdenv.cc.cc
      pkgs.zlib
      pkgs.fuse3
      pkgs.icu
      pkgs.nss
      pkgs.openssl
      pkgs.curl
      pkgs.expat
      pkgs.libx11
      pkgs.libxscrnsaver
      pkgs.libxcomposite
      pkgs.libxcursor
      pkgs.libxdamage
      pkgs.libxext
      pkgs.libxfixes
      pkgs.libxi
      pkgs.libxrandr
      pkgs.libxrender
      pkgs.libxtst
      pkgs.libxcb
      pkgs.libxshmfence
      pkgs.libxkbfile
    ];
  };

  # Variables d'environnement système pour optimiser les performances graphiques (Mesa)
  environment.sessionVariables = {
    vk_xwayland_wait_ready = "false";
    MESA_SHADER_CACHE_MAX_SIZE = "16G";
  };

  # Définition du compte utilisateur principal
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

    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Support du protocole DDC/CI pour contrôler la luminosité des écrans externes
  hardware.i2c.enable = true;

  # Configuration des portails graphiques XDG (portails GNOME/GTK pour Niri)
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

  # Polkit pour la gestion des permissions graphiques (GNOME agent)
  security.polkit.enable = true;

  # Autorisation des paquets non-libres (unfree)
  nixpkgs.config.allowUnfree = true;

  # Autorisation temporaire de paquets marqués non-sécurisés
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
  ];

  # Liste des paquets système indispensables
  environment.systemPackages = with pkgs; [
    xwayland-satellite-unstable
    ffmpeg
    mpvpaper
    socat
    libva-utils
    nvtopPackages.amd
    via
    nvd # Outil de diff des builds de système NixOS
    inputs.omnigraph.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Règles udev pour le clavier VIA / QMK
  services.udev.packages = [pkgs.via];

  # Scrub périodique de maintenance automatisée des disques Btrfs
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

  # Configuration des permissions utilisateur pour les points de montage secondaires
  systemd.tmpfiles.rules = [
    "d /mnt/games 0755 ${username} users -"
    "d /mnt/storage 0755 ${username} users -"
  ];

  # Mémoire virtuelle ZRAM (Swap compressé en RAM)
  zramSwap.enable = true;

  # Service de Trim périodique pour prolonger la durée de vie des disques SSD
  services.fstrim.enable = true;

  # Déduplication et optimisation automatique asynchrone du Nix Store
  nix.optimise.automatic = true;

  # Planificateur CachyOS (sched-ext) avec l'ordonnanceur LAVD (focus graphique)
  services.scx = {
    enable = true;
    scheduler = "scx_lavd"; # Retour vers LAVD, plus stable pour les transitions de focus
  };

  # Configuration des caches binaires tiers (Cachix et dépôts de compilation)
  nix.settings = {
    fallback = true;
    warn-dirty = false;
    substituters = [
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSDs4="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  # Noyau Linux optimisé CachyOS (sched-ext BORE)
  boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos.packages.x86_64-linux.linux-cachyos-bore;

  # Politiques Chromium/Helium pour autoriser les cookies MS et forcer l'installation de Teams
  environment.etc."chromium/policies/managed/helium.json".text = builtins.toJSON {
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

  # Compilation en RAM (tmpfs) pour accélérer le temps de compilation (75% RAM max)
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "75%";

  # Version initiale de l'état système NixOS (ne pas modifier)
  system.stateVersion = "25.11"; # Did you read the comment?
}
