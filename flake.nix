{
  description = "NixOS Unstable avec Home Manager intégré";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel/release";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    omnigraph = {
      url = "path:/home/david/projects/omnigraph";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    muggy = {
      url = "path:/home/david/projects/muggy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages = {
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

      flake = {
        nixosConfigurations.muggy-nixos = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            username = "david";
            hostname = "muggy-nixos";
          };
          modules = [
            ./hosts/system/default.nix
            ./overlays.nix

            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                inputs.omnigraph.homeManagerModules.default
              ];
              home-manager.users.david = {...}: {
                imports = [./home.nix];
                programs.omnigraph.enable = true;
              };
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
