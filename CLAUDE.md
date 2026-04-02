# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **NixOS + Home Manager configuration** repository for a high-performance desktop environment. It combines system-level NixOS config with user-level Home Manager settings, all expressed declaratively in Nix and orchestrated via Flakes.

**Key characteristics:**
- Declarative system and user environment management
- Modular architecture with auto-discovered modules
- Wayland-first (Niri compositor) with GNOME fallback
- Flake-based with unstable + master channels for maximum flexibility

## Build & Apply Commands

The repository uses **`nh`** (Nix helper) for faster rebuilds and better UX. All commands must be run from the repo root.

**Primary workflow:**
- **Apply changes:** `nos` (alias for `nh os switch`)
  - Builds and activates the configuration immediately
  - Fastest way to test changes locally
- **Update flake inputs:** `nix flake update`
  - Updates `flake.lock` to latest upstream versions of dependencies
  - Always run `nos` after updating to apply new versions
- **Cleanup old generations:** `nh clean all`
  - Removes old system/profile generations to reclaim space
  - Safe to run regularly

**Development/testing:**
- **Test build without applying:** `sudo nixos-rebuild build`
  - Catches syntax errors and evaluation failures without touching live system
  - Useful before committing changes
- **View available generations:** `nix-env -p /nix/var/nix/profiles/system --list-generations`

## Repository Architecture

### Directory Structure

```
├── flake.nix                    # Flake definition; entry point for the entire config
├── flake.lock                   # Lock file tracking exact versions of all inputs
├── home.nix                     # Home Manager user config (minimal; modules handle the rest)
├── hosts/
│   └── system/
│       ├── default.nix         # System-level NixOS config (bootloader, hardware, services)
│       └── hardware-configuration.nix  # Generated per-machine; DO NOT EDIT
├── modules/                     # Core building blocks (auto-imported recursively)
│   ├── default.nix             # Auto-scanner that imports all .nix files
│   ├── niri.nix                # Wayland compositor (Niri) + Noctalia shell
│   ├── terminal.nix            # Ghostty terminal configuration
│   ├── zellij.nix              # Zellij terminal multiplexer
│   ├── tmux.nix                # Tmux multiplexer alternative
│   ├── brave.nix               # Brave browser with declarative policies
│   ├── steam.nix               # Gaming setup (Steam, GameMode, Proton)
│   ├── vscode.nix              # VSCode with extensions and settings
│   ├── neovim.nix              # Neovim configuration
│   ├── git.nix                 # Git configuration
│   ├── theme.nix               # GTK/icon themes and cursor settings
│   ├── font.nix                # System fonts
│   ├── performance-tuning.nix   # Kernel, swap, and scheduler optimizations
│   ├── direnv.nix              # Directory-specific environment management
│   ├── nh.nix                  # nh (Nix helper) setup
│   ├── secrets.nix             # SOPS integration for secrets management
│   └── [other modules]         # Discord, Obsidian, PDF tools, music menu, etc.
├── overlays.nix                # Custom package overrides and extensions
└── pkgs/
    └── google-antigravity/     # Custom package definition (Antigravity editor)
```

### Module Pattern

**How modules work:**
- Every `.nix` file in the `modules/` directory (excluding `default.nix`) is **automatically imported**
- `modules/default.nix` uses recursive directory scanning to discover and import all `.nix` files
- Modules define both **NixOS system options** and **Home Manager options**
  - Example: `modules/niri.nix` configures both system-level Wayland services and user-level GUI preferences

**To add a new feature/tool:**
1. Create a new file: `modules/my-feature.nix`
2. Wrap it in a function accepting `{ config, pkgs, inputs, username, hostname, ... }`
3. Define its configuration in the output attrset using `programs.*`, `services.*`, or `home.*` options
4. It will be automatically imported on next rebuild

**Example structure:**
```nix
{ config, pkgs, inputs, username, hostname, ... }:

{
  # NixOS system config
  boot.something = true;
  services.xserver.enable = true;

  # Home Manager config (auto-wired)
  home.file.".config/app/config" = { text = "..."; };
  programs.myapp.enable = true;
}
```

### Key Configuration Files

**flake.nix** (lines 39-74)
- Defines the system output with `nixosSystem`
- Hardcoded values: `username = "david"` and `hostname = "muggy-nixos"` (lines 52-53)
  - These are passed as `specialArgs` to all modules
  - Change here to personalize for different machines
- Combines system config (`hosts/system/default.nix`), modules, overlays, and Home Manager
- Imports multiple flake inputs: nixpkgs (unstable), nixpkgs-master, home-manager, niri, walker, sops-nix, etc.

**hosts/system/default.nix**
- Imports hardware configuration and all modules
- Sets up bootloader (systemd-boot), kernel, AMD GPU drivers, networking, locale
- Enables experimental Nix features (flakes, nix-command)
- Configures greetd (login screen) with tuigreet + niri-session

**home.nix**
- Minimal entry point; mostly handled by auto-imported modules
- Sets username, homeDirectory, stateVersion
- Home Manager is wired as a NixOS module (not standalone)

### Important Design Patterns

**Module Dependencies & Arguments:**
- All modules receive `{ config, pkgs, inputs, username, hostname, lib, ... }`
- Modules can reference each other via `config.<module-path>` (e.g., `config.programs.fish.enable`)
- Do not hardcode usernames; use the `username` argument passed from flake.nix

**Secrets Management (SOPS-Nix):**
- `modules/secrets.nix` integrates `sops-nix` for encrypted secret files
- Secrets are decrypted at build time and mounted into the filesystem
- Reduces risk of committing credentials to the repo

**Hardware-Specific Config:**
- `hosts/system/hardware-configuration.nix` is **auto-generated** and machine-specific
  - Do not manually edit this file; it will be overwritten
  - Contains hardware detection (disks, CPU flags, boot UUID, etc.)
- System-agnostic settings go in `hosts/system/default.nix` or modules

**Flake Inputs Versioning:**
- Most inputs follow `nixpkgs` (via `inputs.nixpkgs.follows`)
- This reduces closure size and avoids dependency conflicts
- Exception: `nixpkgs-master` is independent (for cutting-edge packages)

## Common Development Tasks

### Adding a new application/service
1. Create `modules/myapp.nix`:
   ```nix
   { config, pkgs, ... }:
   { programs.myapp.enable = true; }
   ```
2. Run `nos` to apply
3. Commit with `git add modules/myapp.nix && git commit -m "feat(myapp): add myapp configuration"`

### Updating a package version
- If it's pinned in a module, update the attribute in that module
- If it's from nixpkgs, run `nix flake update` to pull the latest
- Test with `sudo nixos-rebuild build` before applying with `nos`

### Fixing broken builds
- **Syntax errors:** Run `nix flake check` or `sudo nixos-rebuild build` to see the error
- **Module conflicts:** Check if two modules are setting conflicting options (use `config.` to inspect)
- **Missing dependencies:** Ensure the package is in `pkgs` or an overlay is defined

### Testing changes safely
1. Make your change to a module
2. Run `sudo nixos-rebuild build` (builds without applying)
3. If successful, run `nos` to apply
4. If broken, undo changes and rebuild: `nos` reapplies the previous generation

### Switching between terminal multiplexers
- Both `zellij.nix` and `tmux.nix` are included
- They can coexist; enable/disable via `programs.<tool>.enable` in their respective modules
- Zellij is the default and uses the newer layout system

## Debugging & Inspection

**Check what's currently active:**
- `system-profile` (typically shows current system generation)
- `home-manager generations` (list Home Manager generations)
- `nix profile list` (show active profiles if using Nix 2.13+)

**Inspect a module's effect:**
- `grep -r "my-setting" modules/` to find which module sets an option
- `nix-option-search <option-path>` to see NixOS manual docs for an option

**Rollback if needed:**
- `nos --rollback` (or `nh os switch --rollback`)
- This activates the previous generation without rebuilding

## Notes on Recent Changes

The repository is actively maintained with recent focus on:
- **Zellij integration:** Migrated to structured Nix layout attributes + official zjstatus plugin (see commit history)
- **Wayland-first design:** Niri is the primary compositor; GNOME available as fallback
- **Gaming optimizations:** Steam, GameMode, and AMD GPU drivers pre-configured

Check git history for context on major refactors or feature additions.
