# Codebase Concerns

**Analysis Date:** 2026-03-01

## Tech Debt

**Modular Bloat:**
- Issue: Growing number of individual `.nix` modules.
- Impact: Increased build time and configuration complexity.
- Fix approach: Group logically related modules (e.g., `terminal.nix` + `fish.nix` + `starship.nix`).

**Secrets Management:**
- Issue: Mixed use of `.config/antigravity/` and Sops-nix.
- Impact: Difficulty in rotating secrets and non-standard decryption.
- Fix approach: Migrate all secrets to `sops-nix` managed via Home Manager.

## Known Bugs

**Nix Shell and Fish:**
- Symptoms: Occasional shell initialization errors or missing Fish autocompletion.
- Root cause: Incorrect shell integration in Home Manager.
- Fix: Use `programs.fish.enableFishIntegration` consistently.

## Performance Bottlenecks

**Flake Evaluation:**
- Problem: Large Flake with many inputs (`nixpkgs`, `home-manager`, `niri`, `noctalia`).
- Measurement: 3-5s for evaluation before build.
- Improvement path: Prune unused inputs or lock to specific stable revisions.

**System Rebuild (NOS):**
- Problem: Full rebuilds on kernel changes (nix-cachyos).
- Fix: Use pre-built binaries or CachyOS binary caches.

## Fragile Areas

**GSD and Nix Sync:**
- Issue: Files created by GSD agents must be `git add`ed manually for Nix to see them.
- Impact: Builds will fail with "path does not exist" if not added.
- Fix: Automatic `git add` in GSD workflows.

**Noctalia Widgets:**
- Issue: Visual desktop widgets are experimental.
- Impact: High CPU usage or visual artifacts on refresh.
- Fix: Optimize widget scripts in `noctalia.nix`.

---
*Concerns audit: 2026-03-01*
