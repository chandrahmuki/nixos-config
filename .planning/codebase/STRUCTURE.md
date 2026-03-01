# Codebase Structure

**Analysis Date:** 2026-03-01

## Directory Layout

```
nixos-config/
├── .agent/              # AI Agent-specific context (KI, Skills)
├── .gemini/             # GSD scripts and configuration
├── docs/                # User documentation
├── hosts/               # Machine-specific configurations
│   └── muggy-nixos/     # Primary host
├── modules/             # Shared Home Manager modules
├── nvim/                # Neovim configuration (Lua)
├── pkgs/                # Custom Nix packages
├── scripts/             # Custom automation scripts (Go, etc.)
├── secrets/             # Sops-nix encrypted secrets
├── templates/           # Config file templates (fuzzel, mako, etc.)
├── wm/                  # Window manager (Niri) styles and binds
├── flake.nix            # Project entry point
└── home.nix             # Home Manager main entry
```

## Directory Purposes

**hosts/**
- Purpose: System-level and host-specific configurations.
- Key files: `default.nix`, `hardware-configuration.nix`.

**modules/**
- Purpose: Reusable user-level configuration modules.
- Examples: `brave.nix`, `git.nix`, `terminal.nix`.

**pkgs/**
- Purpose: Custom Nix derivations not in nixpkgs.

**secrets/**
- Purpose: Encrypted secrets (YAML) managed via Sops-nix.

## Key File Locations

**Entry Points:**
- `flake.nix` - Global entry point for NixOS and Home Manager.
- `home.nix` - Main import hub for all user modules.

**Core Logic:**
- `hosts/muggy-nixos/default.nix` - System-level configuration.
- `modules/` - Modular configuration of applications and services.

---
*Structure analysis: 2026-03-01*
