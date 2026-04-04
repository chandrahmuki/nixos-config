---
Generated: 2026-04-03 12:30 UTC
---

# Fixes & Resolutions

## Bug : zjstatus vide/noire

**Symptôme** : Zellij affiche une ligne verte vide en bas de l'écran au lieu de la barre de status.

**Cause réelle** : zjstatus n'avait jamais reçu ses permissions Zellij (`ReadApplicationState`, `RunHostCommand`). Sans permissions, le plugin charge mais ne rend rien.

**Cause secondaire** : Le layout `dev.kdl` utilisait `zellij:compact-bar` au lieu de `zjstatus.wasm`.

**Fix** :
1. Corriger le layout pour pointer vers `file:~/.config/zellij/plugins/zjstatus.wasm`
2. Lancer avec `zellij --layout dev` (pas juste `zellij`)
3. Ouvrir le plugin manager (`Ctrl+o → p`) et accorder les permissions à zjstatus
4. Les permissions sont ensuite cachées et persistent entre les sessions

**Note critique** : Sans `--layout dev`, zjstatus ne se charge JAMAIS → le prompt de permissions n'apparaît jamais → cercle vicieux.
