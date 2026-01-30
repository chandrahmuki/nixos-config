{
  description = "NixOS Unstable avec Home Manager intégré";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager pointant sur la branche unstable
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Force HM à utiliser votre version de nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.muggy-nix-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        
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
