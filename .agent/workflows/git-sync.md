---
description: Synchroniser les changements avec Git (Add, Commit, Pull, Push)
---

Ce workflow automatise la synchronisation de votre configuration. Il utilise le skill `commit-pro` pour générer un message de commit propre.

// turbo-all
1. Ajouter tous les fichiers modifiés
```bash
git add .
```

2. Créer un commit avec un message intelligent
On utilise l'IA pour analyser les changements et créer un message au format Conventional Commits.
```bash
# L'assistant génère le message ici
```

3. Récupérer les changements distants (Pull)
On utilise --rebase pour garder un historique propre.
```bash
git pull --rebase
```

4. Envoyer les changements (Push)
```bash
git push
```
