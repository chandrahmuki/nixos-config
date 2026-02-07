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

2. Instructions pour l'agent suivant (Archiviste & Auditeur)
Copiez ce message et collez-le dans une nouvelle session avec l'agent **Archiviste** :

> **[MISSION ARCHIVISTE & AUDITEUR]** 
> 1. **Audit Flash** : Analyse le dernier commit (`git show --stat`) et vérifie la propreté du code (conformité `GEMINI.md`).
> 2. **Vérifie** l'existence d'un **Knowledge Item (KI)** lié aux fichiers modifiés.
> 3. **Priorité absolue** : Crée ou mets à jour le KI dans `~/.gemini/antigravity/knowledge/`.
> 4. (Optionnel) Ajoute un guide dans `./docs` uniquement si nécessaire pour un humain.
> 5. **Focus Chirurgical** : Ne dépasse pas **10 turns**. Sois rapide, précis et conclus dès que le KI est à jour.

Le dépôt est maintenant prêt pour la capitalisation. À bientôt ! 💎🦾
