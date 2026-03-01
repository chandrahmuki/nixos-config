---
name: scratchpad
description: |
  Mémoire vive au format Markdown pour les tâches complexes. À utiliser quand : plus de 5 appels d'outils sont nécessaires, en cas de recherche multi-sources, ou pour des analyses comparatives. 
  Enregistrer le processus → S'y référer pour la réponse → Archiver après usage.
---

# Scratchpad - Mémoire de Travail Avancée (Style Kira)

Le scratchpad est un outil interne permettant de suivre l'avancement d'une tâche complexe sans perdre le fil technique. Cette version améliorée utilise un script Python pour automatisé l'horodatage et la structuration.

## Structure du Skill

- `scripts/scratch_pad.py` : Moteur de journalisation (CLI).
- `references/examples.md` : Modèles d'utilisation.

## Utilisation via CLI

Le script Python permet de gérer le scratchpad de manière structurée :

1.  **Initialisation** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] init "[Task Name]"`
2.  **Journalisation d'outil** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] log-tool "tool_name" '{"param": "val"}' --result "Output"`
3.  **Ajout de découverte** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] finding "Texte de la découverte" --category "Genre"`
4.  **Points de passage** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] checkpoint "Nom de l'étape"`

## Patterns Recommandés

Voir [examples.md](file:///home/david/nixos-config/.agent/skills/scratchpad/references/examples.md) pour les détails sur les patterns :
- **Recherche** : Log des outils et findings.
- **Multi-étapes** : Sections et checkpoints.
- **Analyse** : TODOs et résumés.

## Règles de Conduite

- **Référence interne uniquement** : Ne jamais copier-coller le scratchpad brut dans la réponse à l'utilisateur.
- **Synthèse** : Extraire uniquement les points pertinents pour l'utilisateur.
- **Nomenclature** : Toujours utiliser des chemins absolus pour les fichiers cités.
- **Persistence** : Le fichier doit être créé dans le dossier des artifacts de la session (`/home/david/.gemini/antigravity/brain/[ID]/`).
