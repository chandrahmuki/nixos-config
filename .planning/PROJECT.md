# Project: Global Configuration Cleanup & Refactoring

## Context
The NixOS configuration has accumulated various "leftovers" like backup files, non-standard project organization (source code in `scripts/`), and a brittle `install.sh` that uses `sed` for hostname/username personalization. The goal is to align the repo with NixOS best practices and make it more maintainable and declarative.

### Milestone 2: Fix Noctalia Media Mixer Plugin
The custom Noctalia desktop widget `media-mixer` is failing to accurately map PipeWire audio streams (like MPV and Brave) to their corresponding MPRIS players. 
When selecting a specific audio stream, the widget often controls the wrong player (e.g., clicking MPV controls Brave's playback/artwork). The previous attempt to fix this caused regressions. We need to implement a robust mapping logic.

## Goals
- Clean up NixOS declarative structure (Done).
- Fix `media-mixer` QML plugin so it correctly identifies and controls the currently selected PipeWire stream via MPRIS.
- Ensure play/pause/artwork strictly follows the selected audio stream.

## Tech Stack
- NixOS (Unstable)
- Home Manager
- Bash (Installer)
- Nix Flakes
- QML / Quickshell (Noctalia)
