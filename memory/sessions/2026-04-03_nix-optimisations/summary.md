---
Generated: 2026-04-03
Topic: Nix config optimisations + revue générale
---

## Résumé

Session de revue de la config NixOS + application de plusieurs optimisations. Tout appliqué via `nos` avec succès.

## Commits

- `f896865` — fix: nix optimisations — sysctl dupliqué, cache nix-community, optimise async, registry pin

## Ce qui a été fait

1. **Bug fix** : `boot.kernel.sysctl` défini deux fois dans `performance-tuning.nix` → mergé en un seul bloc
2. **Cache** : ajout `nix-community.cachix.org` pour accélérer les builds HM/sops-nix/neovim
3. **Store optimisation** : `auto-optimise-store = true` → `nix.optimise.automatic = true` (async, non-bloquant)
4. **Registry pin** : `nix.registry.nixpkgs.flake = inputs.nixpkgs` + `nix.nixPath` → `nix shell nixpkgs#foo` instantané et cohérent avec le flake lock
5. **Revert** : `max-jobs = "auto"` retiré — Nix utilise déjà tous les cœurs par build (cores=0 par défaut), max-jobs="auto" causerait de l'oversubscription

## Contexte backup discuté

- Snapshots NVMe (`@snapshots`) : rollback rapide pour `rm -rf` accidentel dans `/home`
- Backups SATA (`/mnt/backup`) : 73G utilisés, 6 mois d'historique
- NVMe : 371G/954G (40%) utilisés
- Sur NixOS, les snapshots locaux ont moins de valeur car tout est reproductible depuis le flake
