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

2. Instructions pour l'agent suivant (Archiviste)
Copiez ce message pour l'agent suivant :
> "1. Analyse le dernier commit avec `git show --stat`.
> 2. **Vérifie** s'il existe déjà un **Knowledge Item** (KI) lié à ces fichiers.
> 3. **Priorité absolue** : Complète ou crée le KI correspondant dans `~/.gemini/antigravity/knowledge/`.
> 4. (Optionnel) Crée un guide dans `./docs` uniquement si c'est utile pour un humain. 
> 5. Respecte le **Budget Turn (max 5-10)** : sois rapide et chirurgical."
