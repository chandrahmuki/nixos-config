# Antigravity Update Procedure

## Overview
This document specifies the exact, official procedure for updating the `google-antigravity` package within this NixOS configuration.

## Update Methodology (Local Package + Overlay)
We do **NOT** use external community derivations (like `jacopone/antigravity-nix`) to manage updates. Instead, we use our own local package definition combined with a custom overly.

### 1. File Locations
- **Local Package Definition**: `/home/david/nixos-config/pkgs/google-antigravity/default.nix`
- **Overlay Declaration**: `/home/david/nixos-config/overlays.nix`

### 2. Update Checklist
Whenever a new version of Antigravity is released, the assistant must perform the following localized update:

1. **Find Latest Version**: Locate the latest version string and the corresponding `Antigravity.tar.gz` download URL.
2. **Fetch Hash**: Use `nix-prefetch-url` with the new URL to obtain the SHA256 / SRI hash.
3. **Edit Package**: Open `pkgs/google-antigravity/default.nix`.
4. **Update Values**:
   - Update `version` to the new version string.
   - Update `sha256` to the newly prefetched hash.
5. **Git Sync**: Run `git add pkgs/google-antigravity/default.nix` so the flake picks up the new source.
6. **Switch Generation**: Run `nos` (or instruct the user to run it) to apply the change.

### 3. Automated Method (Recommended)
You can directly run the custom automated workflow that handles all these steps:
- Use the slash command `/GravityUpdate`.
- This triggers the script located at `.agent/workflows/GravityUpdate.md` which will extract the version, fetch the hash, modify `default.nix`, and stage the changes automatically.

### 4. Critical Rule
**Never** search for alternative repositories to bypass this local update. The custom derivation within `pkgs/google-antigravity/default.nix` contains tailored hacks and environment variables specific to this setup (e.g., FHS workarounds for Antigravity LSP). Only modify the `version` and `sha256` arguments, ideally via the `/GravityUpdate` workflow.
