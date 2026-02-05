---
name: commit-pro
description: Maître des messages de commit, assurant un historique Git propre et professionnel.
---

# Commit Pro Skill

Cette compétence impose l'utilisation des **Conventional Commits** pour maintenir un historique clair et exploitable.

## Format des messages
Chaque commit doit suivre la structure : `<type>(<scope>): <description>`

### Types autorisés
- **feat**: Une nouvelle fonctionnalité (ex: un nouveau module).
- **fix**: Correction d'un bug ou d'un problème de config.
- **docs**: Changement dans la documentation ou les commentaires.
- **style**: Changement de mise en forme (espace, virgule) sans impact fonctionnel.
- **refactor**: Modification du code qui ne change pas le comportement.
- **perf**: Amélioration des performances.

## Règles d'or
1. Message court et explicite (max 72 caractères pour la première ligne).
2. Toujours en anglais (standard de l'industrie).
3. Décrire l'intention du changement.

---
*Note: Cette compétence est activée avant chaque exécution de la commande `git commit`.*
