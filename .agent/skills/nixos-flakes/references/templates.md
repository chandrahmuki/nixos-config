# Nix Templates Reference

## Overview

Templates provide a quick way to bootstrap new Nix projects. Built-in and community templates cover everything from simple scripts to complex NixOS configurations.

## Built-in Templates

```bash
# List available templates in nixpkgs
nix flake show nixpkgs

# Initialize from built-in template
nix flake init -t nixpkgs#hello
```

## Community Templates (Recommended)

### The Nix Way (Modern Standard)
GitHub: `the-nix-way/dev-templates`

| Language | Command |
|----------|---------|
| Node.js | `nix flake init -t github:the-nix-way/dev-templates#node` |
| Python | `nix flake init -t github:the-nix-way/dev-templates#python` |
| Rust | `nix flake init -t github:the-nix-way/dev-templates#rust` |
| Go | `nix flake init -t github:the-nix-way/dev-templates#go` |
| C/C++ | `nix flake init -t github:the-nix-way/dev-templates#cpp` |

## Starter flake.nix Examples

### 1. Minimal Dev Shell
```nix
{
  description = "A simple development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.git pkgs.vim ];
        };
      }
    );
}
```

### 2. Personal NixOS Configuration
```nix
{
  description = "My personal NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.user = import ./home.nix;
        }
      ];
    };
  };
}
```

### 3. Application Package
```nix
{
  description = "A simple application package";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "myapp";
      version = "0.1.0";
      src = ./.;
      buildInputs = [ pkgs.hello ];
      installPhase = ''
        mkdir -p $out/bin
        cp myapp $out/bin/
      '';
    };
  };
}
```

## Creating Your Own Templates

In `flake.nix` of your templates repository:

```nix
{
  description = "My custom templates";

  outputs = { self }: {
    templates = {
      basic = {
        path = ./basic;
        description = "A basic template";
      };
      advanced = {
        path = ./advanced;
        description = "An advanced template";
      };
    };
    defaultTemplate = self.templates.basic;
  };
}
```

## Using Templates

| Task | Command |
|------|---------|
| List templates | `nix flake show github:owner/repo` |
| Initialize (Current Dir) | `nix flake init -t .#template-name` |
| Create New Project | `nix flake new my-project -t .#template-name` |
| Use Registry Template | `nix flake init -t myregistry#template` |

## Tips

1. **Keep it minimal** - Templates should be a starting point, not a complete app.
2. **Use flake-utils** - Simplifies multi-platform support.
3. **Include .envrc** - Add `use flake` to help users with direnv.
4. **README.md** - Briefly explain what's in the template and how to use it.
