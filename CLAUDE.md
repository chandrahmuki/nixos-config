# CLAUDE.md

NixOS + Home Manager configuration for a high-performance desktop (Wayland-first, Niri compositor). Declarative, modular, Flake-based with unstable + master channels.

## Build Commands

All commands from repo root. Uses **`nh`** (Nix helper):

- `nos` — Apply changes (`nh os switch`), builds + activates immediately
- `sudo nixos-rebuild build` — Test build without applying (safe check)
- `nix flake update` — Update all flake inputs, then run `nos`
- `nh clean all` — Remove old generations
- `nos --rollback` — Revert to previous generation

## Architecture

```
flake.nix                    # Entry point; username="david", hostname="muggy-nixos" (lines 52-53)
home.nix                     # Minimal HM entry point; modules handle the rest
hosts/system/default.nix     # Bootloader, AMD GPU, networking, greetd+niri login
hosts/system/hardware-configuration.nix  # AUTO-GENERATED — never edit
modules/                     # Auto-imported recursively via modules/default.nix
overlays.nix                 # Package overrides
pkgs/google-antigravity/     # Custom package
```

## Module Pattern

Every `.nix` in `modules/` is **automatically imported** — just create a file:

```nix
{ config, pkgs, inputs, username, hostname, lib, ... }:
{
  programs.myapp.enable = true;
  home.file.".config/app/config".text = "...";
}
```

- Use `username`/`hostname` args — never hardcode
- Reference other modules via `config.programs.fish.enable`
- Home Manager is wired as a NixOS module (not standalone)

## Session Resume

To resume the last session: run `ls -lt ~/.claude/projects/-home-david-nixos-config/memory/sessions/` to find the most recent dir by mtime, then read its `summary.md` and `todos.md`. Do NOT rely on the order in `index_sessions.md` — it is not sorted by recency.

## Key Design Patterns

- **Secrets:** `modules/secrets.nix` uses SOPS-Nix — encrypted at rest, decrypted at build time
- **Flake inputs:** Most follow `nixpkgs` via `inputs.nixpkgs.follows`; `nixpkgs-master` is independent
- **hardware-configuration.nix** is machine-specific and auto-generated — never touch it
