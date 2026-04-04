---
Generated: 2026-04-03
---

## Bugs fixés

### `boot.kernel.sysctl` dupliqué — performance-tuning.nix
**Symptôme:** Deux blocs `boot.kernel.sysctl = { ... }` dans le même fichier → erreur d'évaluation Nix (`attribute already defined`)
**Fix:** Mergé en un seul bloc avec sections commentées `# Memory Management` et `# Network Optimizations`
**Fichier:** `modules/performance-tuning.nix`

## Optimisations appliquées

- `nix.settings.auto-optimise-store = true` → retiré
- `nix.optimise.automatic = true` → ajouté (planificateur async, ne bloque pas les builds)
- `nix-community.cachix.org` → ajouté aux substituters
- `nix.registry.nixpkgs.flake = inputs.nixpkgs` + `nix.nixPath` → pincés sur le flake lock
- `max-jobs = "auto"` → retiré après explication (Nix utilise déjà tous les cœurs, max-jobs=auto = oversubscription)
