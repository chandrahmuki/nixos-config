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
Copiez le message correspondant à votre besoin :

---

### **Option A : Passer à la REVUE (Auditeur)**
> **[MISSION AUDIT]** 
> 1. Analyse les derniers changements : `git show --stat`.
> 2. Compare le code avec les règles de `GEMINI.md`.
> 3. Liste les optimisations possibles ou valide la conformité.
> 4. Une fois validé, demande à l'utilisateur de passer à la phase ARCHIVE.
> 5. **Focus Chirurgical** : Max 5-10 turns.

---

### **Option B : Passer à la DOCUMENTATION (Archiviste)**
> **[MISSION ARCHIVISTE]** 
> 1. Analyse le commit final : `git show --stat`.
> 2. **Priorité absolue** : Crée ou mets à jour le **Knowledge Item (KI)** dans `~/.gemini/antigravity/knowledge/`.
> 3. (Optionnel) Doc Markdown dans `./docs` pour les humains.
> 4. **Focus Chirurgical** : Max 5-10 turns.

Le dépôt est prêt pour le relais. À bientôt ! 💎🦾

Le dépôt est maintenant prêt pour la capitalisation. À bientôt ! 💎🦾
