# Builds a NixOS system from a host description:
#   settings          identity, locale and the profile lists (see settings.nix)
#   hardwareModule    the host's hardware-configuration.nix
#   extraModules      host-only NixOS modules
#   extraSpecialArgs  extra arguments for the modules
#
# The den aspects are evaluated first, with the settings in scope, to obtain the
# host's main module. That module is then combined with Stylix and Home Manager
# inside nixosSystem.
{inputs}: {
  settings,
  hardwareModule,
  extraModules ? [],
  extraSpecialArgs ? {},
}: let
  inherit (settings) username hostname;
  denConfig =
    (inputs.nixpkgs.lib.evalModules {
      modules = [
        (inputs.import-tree ../aspects)
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
        ../overlays.nix
        denHost.mainModule
        inputs.stylix.nixosModules.stylix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {...}: {
            imports = [../home.nix];
          };
          home-manager.extraSpecialArgs =
            {
              inherit inputs settings username hostname;
            }
            // extraSpecialArgs;
        }
      ]
      ++ extraModules;
  }
