---
Generated: 2026-04-03 18:30 CEST
---

## Bugs Fixed

### Nix 2.31 — all substitutions broken ("public key is not valid")
**Root cause:** The `nix-community.cachix.org-1` trusted public key introduced in commit `f896865` was missing its last character (`4`):
- Broken:  `mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSDs=`  (43 chars — invalid base64)
- Correct:  `mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSDs4=` (44 chars — 32 bytes ed25519)

**Why Nix 2.31 caught it:** Nix 2.31 validates ALL trusted-public-keys at daemon startup. One malformed key causes ALL substitutions to fail (even `nixpkgs#hello`). Previous Nix versions were more lenient.

**Fix applied:**
1. `hosts/system/default.nix` — corrected key in repo
2. `/etc/nix/nix.conf` — patched live with `sed` + `systemctl restart nix-daemon`

**Workaround used for opencode install:** Built packages locally with `--no-substitute` since the daemon couldn't fetch from cache.
