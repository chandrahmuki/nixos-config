# Architecture

**Analysis Date:** 2026-03-01

## Pattern Overview

**Overall:** Modular NixOS with Home Manager Integration (Flake-based).

**Key Characteristics:**
- Declarative and reproducible system and user state.
- Flake-based dependency management (lockfile).
- Modular design with shared modules and host-specific overrides.

## Layers

**System Layer (NixOS):**
- Purpose: System-level configuration (bootloader, drivers, networking).
- Location: `hosts/muggy-nixos/`.
- Depends on: `nixpkgs`.

**User Layer (Home Manager):**
- Purpose: User-specific configuration (applications, dotfiles, services).
- Location: `modules/`, `home.nix`.
- Depends on: System layer, `home-manager`.

**Automation & Custom Logic:**
- Purpose: Custom tools and automation not in standard Nix modules.
- Location: `pkgs/`, `scripts/`, `modules/gemini.nix`.

## Data Flow

**System Rebuild:**
1. User runs `nos` (nh os switch).
2. Nix evaluates `flake.nix`.
3. `nixosConfigurations.muggy-nixos` is resolved.
4. `home-manager` is invoked as a NixOS module.
5. `home.nix` and imported modules in `modules/` are evaluated.
6. System and user configurations are built and applied.

## Key Abstractions

**Modules:**
- Purpose: Encapsulate a single service or app config (e.g., `git.nix`, `brave.nix`).
- Pattern: Nix function returning an attribute set.

**Sops-nix:**
- Purpose: Transparent secret encryption/decryption.
- Pattern: YAML secrets decrypted into the store at runtime.

---
*Architecture analysis: 2026-03-01*
