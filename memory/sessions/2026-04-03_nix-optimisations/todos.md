---
Generated: 2026-04-03
---

## Potentiel futur

- Évaluer si réduire la rétention des snapshots NVMe (`6h 2d` → `2h`) pour économiser de l'espace, vu que sur NixOS tout est reproductible
- Vérifier si `/mnt/storage` contient des données importantes non sauvegardées (btrbk ne couvre que `@home`)
- `services.xserver.enable = true` avec Niri pur → potentiellement inutile, à tester avec précaution
