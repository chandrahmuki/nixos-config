---
Generated: 2026-04-03 UTC
---

# Session Summary — Project Map & Skills Setup

## Contexte
Session de discussion sur le pattern Dendritic NixOS et mise en place d'un système d'indexation de la codebase pour réduire le coût en tokens de chaque conversation.

## Ce qui a été fait

### 1. Discussion Dendritic NixOS + flake-parts
- Explication du pattern : chaque fichier `.nix` est un module top-level, organisation par feature plutôt que par système
- Constat : la config David est déjà ~dendritic (auto-import récursif via `modules/default.nix`)
- Ce qui manque pour être "pur" : fusion NixOS + HM en une seule évaluation via flake-parts
- Décision : flake-parts inutile pour un seul host/user — overhead sans gain réel

### 2. Création du Project Map (`project_map.md`)
Inspiré du projet ai-codex (github.com/skibidiskib/ai-codex) qui génère des index compacts pour assistants AI.

Contenu du map :
- 38 modules indexés avec tags `[nixos]` / `[hm]` / `[both]` / `[secrets]` / `[pkg]`
- Flake inputs (9 inputs avec sources)
- Entry points commentés
- Key design notes

Coût : ~1150 tokens pour charger le map entier vs scanner 5-10 fichiers à l'aveugle.

Instruction ajoutée dans `CLAUDE.md` : lire le map OBLIGATOIREMENT en début de conversation.

### 3. Skill `/project-map`
Créé dans `~/.claude/skills/project-map/SKILL.md`.
Déclenché quand un nouveau module est ajouté — rescanne `modules/` et réécrit `project_map.md`.
Process : `find` pour la liste → inférer le rôle depuis le nom → lire seulement les fichiers ambigus → écrire le map compact.

### 4. Amélioration du skill `/snapshot`
Ajout de l'étape 2 : `git log --oneline -20` pour capturer les commits de la session.
Cross-référence avec l'historique de conversation pour identifier les commits faits pendant la session.

### 5. `memory/backlog.md`
Nouveau fichier créé pour les tâches sans urgence qui se perdaient dans les session snapshots.
Première entrée : rendre les skills portables (chemins hardcodés → variables dynamiques).

### 6. Installation de `find-skills`
`npx skills add https://github.com/vercel-labs/skills --skill find-skills -g -y`
Installé dans `~/.agents/skills/find-skills`, symlinkée dans Claude Code.
Permet de chercher et installer des skills depuis skills.sh directement via l'agent.

## Coût total estimé début de conversation après cette session
| Fichier | ~Tokens |
|---|---|
| CLAUDE.md (auto) | ~400 |
| MEMORY.md (auto) | ~150 |
| project_map.md | ~1150 |
| summary.md + todos.md (session) | ~350 |
| **Total** | **~2050** |
