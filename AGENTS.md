# AGENTS.md - NixOS Configuration Guide

Guidelines for agents working with this NixOS flake-based configuration.

## Knowledge & Memory

- **Session snapshots**: `memory/sessions/<date>_<topic>/summary.md`
- **Project map**: `memory/reference/project_map.md` — check this first for project structure
- **Skills**: `~/.config/opencode/skills/` (project-map, snapshot, find-skills)

## Project Overview

- **Type**: NixOS flake with Home Manager (wired as NixOS module, not standalone)
- **Host**: muggy-nixos (username: david)
- **Architecture**:
  - `flake.nix` — Entry point
  - `home.nix` — Minimal HM entry point; modules handle the rest
  - `hosts/system/default.nix` — Bootloader, AMD GPU, networking, greetd+niri
  - `hosts/system/hardware-configuration.nix` — AUTO-GENERATED, never edit
  - `modules/` — Auto-imported recursively via `modules/default.nix` using `scanModules`
  - `overlays.nix` — Package overrides (niri, opencode, deno fix)
  - `lib/colors.nix` — Shared Tokyonight color palette

## Commands

```bash
# Deploy (uses nh)
nos

# Fast syntax check (no build, no sudo)
nix eval .#nixosConfigurations.muggy-nixos.config.home-manager.users.david.home.stateVersion

# Thorough validation (builds derivations)
sudo nixos-rebuild build

# Update all flake inputs, then deploy
nix flake update && nos

# Revert to previous generation
nos --rollback

# Remove old generations
nh clean all

# Lint & format
alejandra --check .
deadnix --check .
statix check .
```

## Code Style

### Module Template

```nix
{ config, lib, pkgs, username, inputs, ... }:

{
  imports = [ ];

  # NixOS-level config
  programs.niri.enable = true;

  # Home Manager config
  home-manager.users.${username} = { config, lib, ... }: {
    # HM settings here
  };
}
```

### Key Rules

- **Parameters**: System modules = `{ config, lib, pkgs, ... }` | Home modules = `{ config, lib, pkgs, username, inputs, ... }`
- **Never hardcode** `david` or `muggy-nixos` — use `username`/`hostname` args
- **Package refs**: `pkgs.jq` for packages, `"${pkgs.pamixer}/bin/pamixer"` for bin paths, `inputs.<name>` for flake inputs
- **Shared colors**: `let colors = (import ../lib/colors.nix).tokyonight; in` then `colors.bg`, `colors.fg`, `colors.blue`, etc.
- **New modules**: Create `modules/<name>.nix` — auto-imported, no manual registration needed
- **Settings over extraConfig**: Prefer `settings` attribute for HM programs
- **Conditional config**: `lib.mkIf`, defaults: `lib.mkDefault`, overrides: `lib.mkForce`
- **Indentation**: 2 spaces, one list element per line
- **No comments** unless asked

### Lint & Format Tools

- **alejandra** — Nix formatter (replaces nixfmt)
- **deadnix** — Detects unused bindings (dead code)
- **statix** — Suggests improvements (with → inherit, etc.)

Run all three before committing.

## Secrets

- `modules/secrets.nix` uses SOPS-Nix — encrypted at rest, decrypted at build time
- Never commit secrets to the repo

## Troubleshooting

- Debug builds: `nixos-rebuild build --show-trace`
- List options: `nix repl` then `:l nixpkgs.lib.nixosSystem`

## Session Resume

**NEVER use glob/ls on memory/sessions/** — direct read only!
```bash
# Get latest session dir name:
ls -t /home/david/nixos-config/memory/sessions/ | head -1
# Then read that session's summary.md directly
cat /home/david/nixos-config/memory/sessions/<latest>/summary.md
```

## Interaction Rules

- **Always ask before taking action** — Never delete, modify, or commit files without explicit permission
- When asked to update git, first check what needs to be staged and ask for confirmation before committing
- **Always `git add` new files** — After creating any new file, run `git add <path>` immediately or the flake won't pick it up

## Verification Workflow

After ANY change to `.nix` files, run `nix eval` to catch errors. Fix before telling the user the change is done. For thorough validation, run `sudo nixos-rebuild build`.