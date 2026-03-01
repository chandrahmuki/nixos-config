# Testing Patterns

**Analysis Date:** 2026-03-01

## Test Framework

**System:**
- `nh os switch` - the primary verification command.
- Dry-run: `nh os test` (if supported) or `nixos-rebuild test`.

**Custom Scripts (Go):**
- `go test` - for the `muggy` script library.

## Verification Workflow

**NixOS:**
1. User modifies a `.nix` module.
2. User runs `nos` (nh os switch).
3. NixOS evaluates and builds the configuration.
4. If success, the system switches to the new profile.

**AI Verification:**
- Manual tests of newly installed apps/services.
- Visual inspection of desktop widgets (Noctalia).
- Verification of secrets decryption (Sops-nix).

## Common Patterns

**System-level:**
- `nix flake check` - verifies the Flake's integrity.
- `nix build .#nixosConfigurations.muggy-nixos.config.system.build.toplevel` - dry-build to ensure no syntax errors.

---
*Testing analysis: 2026-03-01*
