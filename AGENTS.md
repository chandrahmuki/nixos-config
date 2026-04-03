# AGENTS.md - NixOS Configuration Guide

This document provides guidelines for agents working with this NixOS flake-based configuration.

## Project Overview

- **Type**: NixOS flake configuration with Home Manager
- **Flake inputs**: nixpkgs (nixos-unstable), home-manager, niri, noctalia, nix-cachyos, walker, elephant, sops-nix
- **Host**: muggy-nixos (username: david)
- **Architecture**:
  - `flake.nix` — Entry point; username="david", hostname="muggy-nixos"
  - `home.nix` — Minimal HM entry point; modules handle the rest
  - `hosts/system/default.nix` — Bootloader, AMD GPU, networking, greetd+niri login
  - `hosts/system/hardware-configuration.nix` — AUTO-GENERATED, never edit
  - `modules/` — Auto-imported recursively via modules/default.nix
  - `overlays.nix` — Package overrides
  - `pkgs/google-antigravity/` — Custom package

## Build/Deploy Commands
```bash
# Primary command - uses 'nh' for faster builds (Recommended)
nos

# Test build without applying (safe check)
sudo nixos-rebuild build

# Update all flake inputs, then run nos
nix flake update

# Remove old generations
nh clean all

# Revert to previous generation
nos --rollback
```

## Code Style Guidelines

### Module Structure

Each module file should follow this pattern:
```nix
{ config, lib, pkgs, username, inputs, ... }:

{
  imports = [ ];

  # Option 1: NixOS-only configuration
  programs.niri.enable = true;

  # Option 2: Home Manager user configuration
  home-manager.users.${username} = { config, lib, ... }: {
    # HM settings here
  };
}
```

### Imports

- Modules are auto-discovered via `modules/default.nix` using `scanModules`
- No need to manually add imports to `home.nix` - they load automatically
- System-level imports go in `hosts/system/default.nix`
- Home Manager is wired as a NixOS module (not standalone)
- Use `username`/`hostname` args — never hardcode
- Reference other modules via `config.programs.<name>.enable`

### Settings Structure (Home Manager)

Use the new `settings` structure for Home Manager programs:
```nix
programs.git = {
  enable = true;
  settings = {
    user.name = username;
    user.email = "email@example.com";
    alias.s = "status";
  };
};
```

Avoid legacy `extraConfig` - use `settings` instead.

### Parameter Types

- **System modules**: `{ config, lib, pkgs, ... }`
- **Home modules**: `{ config, lib, pkgs, username, inputs, ... }`
- **Host modules**: `{ config, lib, pkgs, username, hostname, inputs, ... }`

### Nix Language Conventions

1. **Indentation**: 2 spaces
2. **Attribute sets**: Use `=` for assignments, `:` for inherits
3. **Functions**: Use `{ ... }` lambda syntax
4. **Lists**: One element per line for readability

### Naming Conventions

- Files: `kebab-case.nix`
- Options: `camelCase` (Nix convention)
- Attribute names: `camelCase` or `kebab-case` based on context

### Error Handling

- Use `lib.mkIf` for conditional configuration
- Use `lib.mkDefault` for sensible defaults
- Use `lib.mkForce` to override unconditionally

### Package References

```nix
# Package from pkgs
home.packages = [ pkgs.jq ];

# With bin path
"${pkgs.pamixer}/bin/pamixer"

# Flake input package
inputs.niri.nixosModules.niri
```

## Common Patterns

### Adding a New Module

1. Create `modules/<module-name>.nix`
2. Follow the parameter pattern above
3. Auto-imported via `modules/default.nix`

### Working with Secrets (sops-nix)

- Secrets go in `modules/secrets.nix`
- Use sops-nix for sensitive data
- Never commit secrets to the repo

## Editor Integration

### VSCode
The `modules/vscode.nix` provides VSCode configuration. Use the Nix language server.

### Neovim
`modules/neovim.nix` provides Neovim configuration with Nix LSP support.

## Troubleshooting

- Check generated hardware config: `hosts/system/hardware-configuration.nix`
- Debug builds: `nixos-rebuild build --show-trace`
- List all options: `nix repl` then `:l nixpkgs.lib.nixosSystem`

## Session Resume

**NEVER use glob/ls on memory/sessions/** — direct read only!
```
# Get latest session dir name:
ls -t ~/.claude/projects/-home-david-nixos-config/memory/sessions/ | head -1
# Then read that session's summary.md directly
cat ~/.claude/projects/-home-david-nixos-config/memory/sessions/<latest>/summary.md
```

## Key Design Patterns

- **Secrets:** `modules/secrets.nix` uses SOPS-Nix — encrypted at rest, decrypted at build time
- **Flake inputs:** Most follow `nixpkgs` via `inputs.nixpkgs.follows`; `nixpkgs-master` is independent
- **hardware-configuration.nix** is machine-specific and auto-generated — never touch it
