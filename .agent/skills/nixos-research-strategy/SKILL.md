---
name: nixos-research-strategy
description: |
  Stratégies de recherche systématique pour NixOS. Fournit des arbres de décision pour naviguer dans la documentation web et le code source de Nixpkgs.
  Utiliser pour déterminer la profondeur de lecture et choisir les bons outils (Fetch, GitHub MCP, Nix Search).
---

# NixOS Research Strategy

Guide stratégique pour l'exploration systématique de l'écosystème NixOS.

## Niveaux de Recherche

### 1. ⚡ Quick Scan (Recherche Rapide)
- **Quand** : Questions de syntaxe simple, vérification de version.
- **Action** : `Nix Search` pour les options, lecture du `README.md` via `Fetch`.
- **Objectif** : Une réponse immédiate basée sur la documentation officielle.

### 2. 🛡️ Standard Trace (Analyse Standard)
- **Quand** : Configuration de nouveaux modules, erreurs de build courantes.
- **Action** : `Quick Scan` + lecture du code du module dans Nixpkgs via `GitHub MCP`.
- **Objectif** : Comprendre comment les options sont implémentées.

### 3. 🔬 Nix-Deep-Dive (Immersion Totale)
- **Quand** : Bugs obscurs, comportements non documentés, intégration de flakes complexes.
- **Action** : `Standard Trace` + recherche d'issues GitHub, lecture des Pull Requests liées pour comprendre le "pourquoi" derrière une implémentation.
- [ ] **Objectif** : Résoudre des problèmes d'architecture ou des bugs de bas niveau.

### ⚡ 4. Surgical Context (Analyse Interne)
- **Quand** : Travailler sur des changements récents faits par un autre agent.
- **Action** : `git show --stat` (immédiat) ou lecture de `repomix-nixos-config.md`.
- **Objectif** : Identifier instantanément les fichiers modifiés sans scanner tout le projet.

## Arbre de Décision

```
Requête Utilisateur
├── Mots-clés : "Pourquoi", "Bizarre", "Bug", "Interne"
│   → **NIX-DEEP-DIVE**
│   → Outils : GitHub Search (Code + Issues + PRs)
│
├── Mots-clés : "Comment configurer", "Options pour"
│   → **STANDARD TRACE**
│   → Outils : Nix Search + View Contents (module.nix)
│
└── Mots-clés : "Est-ce que", "Version", "Qu'est-ce que"
    → **QUICK SCAN**
    → Outils : Nix Search + Fetch (README)
```

## Meilleures Pratiques
- **Toujours remonter à la source** : Le code source de Nixpkgs est la source de vérité ultime.
- **Vérifier l'historique** : Une option qui a changé de nom est souvent documentée dans le commit qui l'a modifiée.
- **Documenter la recherche** : Utiliser le skill `scratchpad` pour noter les fichiers parcourus.
