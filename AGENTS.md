# AGENTS.md — NixOS Flake Config

**Type**: NixOS flake + HM (NixOS module) | **Host**: muggy-nixos | **User**: david

## Structure
- `flake.nix` — Entry point
- `home.nix` — Minimal HM entry; modules handle the rest
- `hosts/system/default.nix` — Bootloader, AMD GPU, greetd+niri
- `hosts/system/hardware-configuration.nix` — AUTO-GENERATED, never edit
- `modules/*.nix` — Auto-imported via `scanModules` in `modules/default.nix`
- `overlays.nix` — Package overrides (niri, opencode, deno, openldap)
- `lib/colors.nix` — Shared Tokyonight palette

## Commands
```
nos                                    # Deploy (nh)
nix eval .#nixosConfigurations.muggy-nixos.config.home-manager.users.david.home.stateVersion  # Syntax check
sudo nixos-rebuild build               # Thorough validation
nix flake update && nos                 # Update + deploy
nos --rollback                          # Revert
alejandra --check . && deadnix --check . && statix check .  # Lint+format
```

## Code Style
- Params: system=`{config,lib,pkgs,...}` | HM=`{config,lib,pkgs,username,inputs,...}`
- Never hardcode `david`/`muggy-nixos` — use `username`/`hostname` args
- Pkg refs: `pkgs.jq` | bin paths: `"${pkgs.pamixer}/bin/pamixer"` | flake: `inputs.<name>`
- Colors: `let colors=(import ../lib/colors.nix).tokyonight; in` then `colors.bg`, `colors.fg`, `colors.blue`
- New modules: `modules/<name>.nix` — auto-imported
- Prefer `settings` over `extraConfig` | `lib.mkIf` / `lib.mkDefault` / `lib.mkForce`
- 2-space indent | no comments unless asked

## Rules
- Always ask before delete/modify/commit
- `git add` new files immediately (flake needs it)
- After `.nix` changes: run `nix eval` to verify
- Secrets: `modules/secrets.nix` uses SOPS-Nix
- Session resume: `/omnigraph session-resume` (queries graph for last session context + summary)
- Every 15 messages: remind user to run `/compact` now to save tokens

## OmniGraph
- Skill: `/omnigraph <command>` — check, query, orphans, session-resume
- Before editing `.nix`: `/omnigraph check <file>` for deps, sessions, lessons, risk
- After snapshot: graph DB updated automatically via snapshot skill
- Periodically: `/omnigraph orphans` to detect unused inputs and dead refs

