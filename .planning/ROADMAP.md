# Roadmap: Global Cleanup & Refactoring

## Phase 1: Housekeeping (Filesystem Cleanup) [COMPLETED]
- [x] Remove `modules/gemini.nix.bak`.
- [x] Search for and remove other `.bak`, `.tmp`, or hidden leftovers.
- [x] Clean up `generated/` files (verified as managed by Matugen/HM).

## Phase 2: Declarative Variable Refactoring [COMPLETED]
- [x] Refactor `flake.nix` to use `username` and `hostname` in `specialArgs`.
- [x] Update `hosts/system/default.nix` and `home.nix` to use these variables.
- [x] Update `install.sh` to update `flake.nix` instead of using `sed` on multiple files.

## Phase 3: Package Structure Refactoring [COMPLETED]
- [x] Move Go source from `scripts/muggy/` to `pkgs/muggy/src/`.
- [x] Review `scripts/` to ensure only actual utility scripts remain.
- [x] Consolidate `templates/` with Home Manager modules if possible.

## Final Review & Validation [COMPLETED]
- [x] Renamed `hosts/muggy-nixos` to `hosts/system` for host-agnostic pathing.
- [x] Verified `flake.nix` path updates.
- [x] Final cleanup of placeholders in `install.sh`.
