# Project: Global Configuration Cleanup & Refactoring

## Context
The NixOS configuration has accumulated various "leftovers" like backup files, non-standard project organization (source code in `scripts/`), and a brittle `install.sh` that uses `sed` for hostname/username personalization. The goal is to align the repo with NixOS best practices and make it more maintainable and declarative.

## Goals
- Remove all stray backup and temporary files.
- Refactor the installation process to be fully declarative using `specialArgs`.
- Reorganize `scripts/` and `pkgs/` to follow standard package structures.
- Move static configurations from `generated/` into Home Manager modules where possible.

## Tech Stack
- NixOS (Unstable)
- Home Manager
- Bash (Installer)
- Nix Flakes
