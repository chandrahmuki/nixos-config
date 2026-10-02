{
  description = "NixOS Unstable avec Home Manager intégré";

  # External package sources and channels (inputs)
  inputs = {
    # Main and development Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # User configuration tools and managers
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utility to structure the flake in modules
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";
    den.url = "github:denful/den";

    # CachyOS optimised Linux kernel
    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Secret encryption and management (SOPS-Nix)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Zen Browser web browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Minimalist Chromium browser Helium
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System-wide and user theming
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    muggy = {
      url = "git+ssh://git@github.com/chandrahmuki/muggy.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    omnigraph = {
      url = "github:chandrahmuki/OmniGraph";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake outputs
  outputs = inputs: let
    publicSettings = import ./settings.nix;
    mkNixosConfiguration = {
      settings,
      hardwareModule,
      extraModules ? [],
      extraSpecialArgs ? {},
    }: let
      inherit (settings) username hostname;
      denConfig =
        (inputs.nixpkgs.lib.evalModules {
          modules = [
            (inputs.import-tree ./aspects)
            inputs.den.flakeOutputs.flake
          ];
          specialArgs =
            {
              inherit inputs settings;
            }
            // extraSpecialArgs;
        }).config;
      denHost = denConfig.den.hosts.${settings.system}.desktop;
    in
      inputs.nixpkgs.lib.nixosSystem {
        inherit (settings) system;
        specialArgs =
          {
            inherit inputs settings username hostname;
          }
          // extraSpecialArgs;
        modules =
          [
            hardwareModule
            ./overlays.nix
            denHost.mainModule
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = {...}: {
                imports = [./home.nix];
              };
              home-manager.extraSpecialArgs =
                {
                  inherit inputs settings username hostname;
                }
                // extraSpecialArgs;
            }
          ]
          ++ extraModules;
      };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [publicSettings.system];

      # Per-system configuration
      perSystem = {pkgs, ...}: let
        # Only the Nix files: keeps the check sources small and makes the
        # checks independent of wallpapers, QML and the like.
        nixSources = pkgs.lib.fileset.toSource {
          root = ./.;
          fileset = pkgs.lib.fileset.union ./statix.toml (pkgs.lib.fileset.fileFilter (file: file.hasExt "nix") ./.);
        };
        mkCheck = name: tools: command:
          pkgs.runCommand "check-${name}" {nativeBuildInputs = tools;} ''
            cd ${nixSources}
            ${command}
            touch $out
          '';
      in {
        formatter = pkgs.alejandra;

        checks = {
          format = mkCheck "format" [pkgs.alejandra] "alejandra --check .";
          # Unused bindings; lambda argument names are left alone because the
          # aspects deliberately accept the usual { config, lib, pkgs, ... }.
          deadnix = mkCheck "deadnix" [pkgs.deadnix] "deadnix --fail --no-lambda-pattern-names .";
          statix = mkCheck "statix" [pkgs.statix] "statix check .";
          # Syntax of the code kept in files/ (Lua, JavaScript, shell). The real
          # validation of hyprland.lua is Hyprland --verify-config in the VM.
          payload-syntax =
            pkgs.runCommand "check-payload-syntax" {
              nativeBuildInputs = [pkgs.lua5_4 pkgs.nodejs pkgs.bash];
            } ''
              cd ${pkgs.lib.fileset.toSource {
                root = ./.;
                fileset = ./files;
              }}/files
              for f in */*.lua; do luac -p "$f"; done
              for f in */*.cjs; do node --check "$f"; done
              for f in */*.sh; do bash -n "$f"; done
              touch $out
            '';
        };
      };

      # Global system configuration
      flake = {
        lib.mkNixosConfiguration = mkNixosConfiguration;

        nixosConfigurations = {
          # Personal machine
          muggy-nixos = mkNixosConfiguration {
            settings = import ./hosts/muggy-nixos/settings.nix;
            hardwareModule = ./hosts/muggy-nixos/hardware-configuration.nix;
            extraModules = [
              ({
                config,
                pkgs,
                settings,
                ...
              }: {
                environment.systemPackages = [
                  pkgs.handy
                  pkgs.wtype
                ];
              })
            ];
          };

          # Generic configuration / template for any user
          generic = mkNixosConfiguration {
            settings = publicSettings;
            hardwareModule = ./hosts/system/hardware-configuration.nix;
          };

          default = mkNixosConfiguration {
            settings = publicSettings;
            hardwareModule = ./hosts/system/hardware-configuration.nix;
          };
        };
      };
    };
}
