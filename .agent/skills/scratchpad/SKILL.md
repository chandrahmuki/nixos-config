---
name: scratchpad
description: |
  Mémoire vive au format Markdown pour les tâches complexes. À utiliser quand : plus de 5 appels d'outils sont nécessaires, en cas de recherche multi-sources, ou pour des analyses comparatives. 
  Enregistrer le processus → S'y référer pour la réponse → Archiver après usage.
---

# Scratchpad - Mémoire de Travail Structurée

Le scratchpad est un outil interne permettant de suivre l'avancement d'une tâche complexe sans perdre le fil technique.

## Utilisation Rapide

1. **Initialisation** : Créer un fichier `scratchpad.md` dans le répertoire des artifacts de la conversation en cours.
2. **Journalisation** : Noter chaque étape importante, les découvertes et les impasses.
3. **Synthèse** : Utiliser le contenu pour formuler la réponse finale à l'utilisateur.

## Structure Recommandée

```markdown
# 📋 Tâche : [Nom de la tâche]

## 📝 Objectif
[Bref résumé de ce qu'on essaie d'accomplir]

## 🔍 Journal des Découvertes
- [HEURE] : Trouvé l'option `services.niri.enable` dans `nixpkgs/wayland/niri.nix`.
- [HEURE] : Erreur lors du build : "X11 missing". Hypothèse : besoin de xwayland-satellite.

## 🔧 État des Outils
- GitHub MCP : Utilisé pour inspecter `sodiboo/niri-flake`.
- Nix Search : Confirme la version 0.1.0 stable.

## ✅ TODO / Checkpoints
- [x] Identifier le module
- [/] Tester la config
- [ ] Documenter le fix
```

## Règles de Conduite
- **Référence interne uniquement** : Ne pas copier-coller le scratchpad brut dans la réponse à l'utilisateur.
- **Synthèse** : Extraire uniquement les points pertinents pour l'utilisateur.
- **Nomenclature** : Toujours utiliser des chemins absolus pour les fichiers cités.
