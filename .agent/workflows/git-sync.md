---
description: Synchroniser les changements avec Git (Add, Review, Commit, Pull, Push)
---

Ce workflow automatise la synchronisation complète. Il inclut désormais une phase de **Code Review** pour garantir la qualité avant le commit.

// turbo-all
1. Préparer les changements
```bash
git add .
```

2. Revue de Code Automatisée
L'assistant analyse les changements indexés, vérifie la conformité avec `GEMINI.md` et propose des optimisations via le skill `architect`.
```bash
git diff --cached --stat
# [INTERNAL REVIEW] : L'IA analyse maintenant le contenu détaillé de ces fichiers...
```

3. Créer un commit avec un message intelligent
On utilise `commit-pro` pour générer un message au format Conventional Commits.
```bash
# L'assistant génère le message ici
```

4. Récupérer les changements distants (Pull)
```bash
git pull --rebase
```

5. Envoyer les changements (Push)
```bash
git push
```
