---
description: Automatisation de la documentation et de la synchronisation après un changement.
---

Ce workflow permet de boucler une tâche proprement en minimisant la recherche aveugle des sous-agents.

// turbo-all
// turbo-all
1. Synchronisation Git chirurgicale (sans Repomix pour la vitesse)
```bash
git add . && git commit -m "docs: synchronization and context update" && git push
```

2. Instructions pour l'agent suivant (Relais Triple)
Ouvrez une nouvelle session avec un nouvel agent et tapez simplement :

- **`/audit`** : Pour lancer une revue de code (Auditeur).
- **`/archive`** : Pour capitaliser le savoir (Archiviste).

Le dépôt est prêt pour le relais. À bientôt ! 💎🦾

Le dépôt est maintenant prêt pour la capitalisation. À bientôt ! 💎🦾
