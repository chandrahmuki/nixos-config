# NixOS Portability Patterns

## Centralized Username
To allow the configuration to be used by different users without manual search-and-replace:
1. Define a `username` variable in `flake.nix`.
2. Pass it to modules via `specialArgs` (NixOS) and `extraSpecialArgs` (Home Manager).

```nix
# flake.nix
outputs = { self, nixpkgs, ... }@inputs:
let
  username = "david";
in {
  nixosConfigurations.muggy-nixos = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs username; };
    # ...
  };
};
```

## Abstracting Paths
Avoid hardcoded `/home/david/` paths.

### In Home Manager Modules
Use `${config.home.homeDirectory}`:
```nix
flake = "${config.home.homeDirectory}/nixos-config";
```

### In NixOS Modules
Use interpolation with the passed `username`:
```nix
"L+ /run/gdm/.config/monitors.xml - - - - /home/${username}/.config/monitors.xml"
```

## User Identifiers
Use computed attribute names:
```nix
users.users.${username} = { ... };
home-manager.users.${username} = import ./home.nix;
```

## Automation Leverage
These portability patterns are designed to be exploited by bootstrap scripts (see `bootstrap_patterns.md`). By centralizing variables and using placeholders (like `muggy-nixos`), a simple `sed` replacement during install can personalize the entire system without complex Nix parsing.
