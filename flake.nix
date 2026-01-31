{
  description = "NixOS Unstable avec Home Manager intégré";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager pointant sur la branche unstable
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Force HM à utiliser votre version de nixpkgs
    };

    # Flake niri
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        quickshell.inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      niri,
      dms,
      ...
    }@inputs:
    {
      nixosConfigurations.muggy-nix-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./overlays.nix

          # Le module DMS se charge au niveau SYSTEME
          dms.nixosModules.dank-material-shell
          niri.nixosModules.niri # Le module Niri Système (Sodiboo)

          # Import du module Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.david = import ./home.nix;

            # Optionnel : passe les 'inputs' du flake au fichier home.nix
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
}
