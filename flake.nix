{
  description = "NixOS Unstable avec Home Manager intégré";

  # Dépôts de paquets et canaux externes (Inputs)
  inputs = {
    # Dépôts Nixpkgs principaux et de développement
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # Version figée de Nixpkgs pour Mesa 26.1.2 afin d'éviter les crashs multi-écrans Parsec
    nixpkgs-mesa.url = "github:nixos/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";

    # Outils et gestionnaires de configuration utilisateur
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Compositeur Wayland Niri
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilitaire de structuration modulaire de flake
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";
    den.url = "github:denful/den";

    # Composants du shell utilisateur Noctalia
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noyau Linux optimisé CachyOS
    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Chiffrement et gestion des secrets (SOPS-Nix)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Provider d'intelligence artificielle OpenCode
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Navigateur web Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Navigateur minimaliste Chromium Helium
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Base de données de dépendances de projet
    omnigraph = {
      url = "path:/home/david/projects/omnigraph";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application compagnon locale Muggy
    muggy = {
      url = "git+file:///home/david/projects/muggy?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Thémage global système et utilisateur
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Outil de gestion des services Systemd utilisateur
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Définition des sorties (Outputs) du flake
  outputs = inputs: let
    denConfig =
      (inputs.nixpkgs.lib.evalModules {
        modules = [
          (inputs.import-tree ./aspects)
          inputs.den.flakeOutputs.flake
        ];
        specialArgs.inputs = inputs;
      }).config;
    denHost = denConfig.den.hosts.x86_64-linux.muggy-nixos;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      # Configuration spécifique pour chaque système
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        # Paquets personnalisés compilés par le flake
        packages = {
          # Installateur de l'agent CLI Antigravity
          antigravity-cli = pkgs.stdenvNoCC.mkDerivation {
            name = "antigravity-cli-1.0.6";
            src = pkgs.fetchurl {
              url = "https://github.com/google-antigravity/antigravity-cli/releases/download/1.0.6/agy_cli_linux_x64.tar.gz";
              sha256 = "3eae552781d3054b782142e3cfe7be73e3bd068c736a432ca6f1adaa40f19e07";
            };
            sourceRoot = ".";
            nativeBuildInputs = [
              pkgs.autoPatchelfHook
            ];
            buildInputs = [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
            ];
            installPhase = ''
              install -m755 -D antigravity $out/bin/agy
            '';
          };
        };
      };

      # Configuration système globale
      flake = {
        # Définition de la machine 'muggy-nixos'
        nixosConfigurations.muggy-nixos = inputs.nixpkgs.lib.nixosSystem {
          # Paramètres transmis à l'ensemble des modules NixOS
          specialArgs = {
            inherit inputs;
            username = "david";
            hostname = "muggy-nixos";
          };
          # Liste des modules à charger
          modules = [
            ./hosts/system/default.nix
            ./overlays.nix
            denHost.mainModule

            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.home-manager

            # Configuration intégrée de Home Manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                inputs.omnigraph.homeManagerModules.default
              ];
              # Profil utilisateur pour 'david'
              home-manager.users.david = {...}: {
                imports = [./home.nix];
                programs.omnigraph.enable = true;
              };
              # Arguments transmis aux configurations Home Manager
              home-manager.extraSpecialArgs = {
                inherit inputs;
                username = "david";
                hostname = "muggy-nixos";
              };
            }
          ];
        };
      };
    };
}
