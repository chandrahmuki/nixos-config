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

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel/release";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      home-manager,
      niri,
      noctalia,
      nix-cachyos,
      sops-nix,
      ...
    }@inputs:
    let
      username = "david";
      hostname = "muggy-nixos";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./hosts/system/default.nix
          ./overlays.nix

          noctalia.nixosModules.default
          niri.nixosModules.niri
          sops-nix.nixosModules.sops

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs username hostname; };
          }
        ];
      };
    };
}
