---
description: Automatisation de la documentation et de la synchronisation après un changement.
---

Ce workflow permet de boucler une tâche proprement en minimisant la recherche aveugle des sous-agents.

// turbo-all
1. Exécution chirurgicale (Context + Git + Push) en une seule étape
```bash
repomix --output repomix-nixos-config.md && git add . && git commit -m "docs: synchronization and context update" && git push
```

2. Instructions pour l'agent suivant
Copiez ce message pour l'agent Archiviste :
> "Analyse le dernier commit avec `git show --stat`. Ton objectif final est de créer un **Knowledge Item** (mémoire IA) ou un fichier Markdown dans `./docs` (mémoire humaine). Ne te contente pas de remplir ton scratchpad : produit un document utile et durable."
