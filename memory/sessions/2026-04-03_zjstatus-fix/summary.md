---
Generated: 2026-04-03 12:30 UTC
---

# Session Summary

## Problème résolu

zjstatus (barre de status Zellij) affichait une ligne vide/noire depuis 2 jours malgré des dizaines de tentatives.

## Ce qui a été fait

- Identifié que le layout actuel utilisait `compact-bar` au lieu de zjstatus
- Corrigé `modules/zellij.nix` : layout `dev.kdl` migré vers zjstatus avec config complète (mode, session, tabs, git branch, heure)
- Ajouté fonction fish `zj` pour attach rapide à la session "main"
- Diagnostiqué la vraie cause du bug : permissions zjstatus jamais accordées
- **Fix final** : lancer `zellij --layout dev` puis accorder les permissions via `Ctrl+o → p` (plugin manager)
