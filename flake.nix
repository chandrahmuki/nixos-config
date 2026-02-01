{
  description = "NixOS Unstable avec Home Manager intégré";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

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
    antigravity = {
      url = "github:jacopone/antigravity-nix";
      # C'est ici que la magie opère :
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS Latest Kernel (xddxdd - has lantian cache)
    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      home-manager,
      niri,
      antigravity,
      dms,
      nix-cachyos,
      ...
    }@inputs:
    {
      nixosConfigurations.muggy-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/muggy-nixos/default.nix
          ./overlays.nix

          # CachyOS kernel is set via boot.kernelPackages in default.nix

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
