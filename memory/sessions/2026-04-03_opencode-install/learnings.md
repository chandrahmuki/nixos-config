---
Generated: 2026-04-03 18:30 CEST
---

## Learnings

- Nix 2.31 validates trusted-public-keys at daemon startup — a single malformed key blocks ALL substitutions globally
- Diagnosis: `nix build nixpkgs#hello` failing = systemic daemon issue, not package-specific
- A 44-char base64 string is required for ed25519 keys; 43 chars = invalid padding
- When the nix daemon has a broken config, `nos` can still succeed if all needed packages are already in the store or built with `--no-substitute`
- After manually patching `/etc/nix/nix.conf`, must `sudo systemctl restart nix-daemon` for changes to take effect
