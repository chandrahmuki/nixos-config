---
name: context-switch
description: Basculer de tâche proprement, archiver le savoir et optimiser les tokens (SANS redémarrage).
---

Ce workflow permet de fermer un sujet de travail et d'en ouvrir un nouveau tout en minimisant la consommation de tokens.

// turbo-all
1. Archivage de la Tâche Actuelle
Utiliser le skill `knowledge-archivist` pour condenser l'essentiel du travail effectué dans un **Knowledge Item (KI)**.
- Cela permet de "libérer" la mémoire de travail détaillée.
- Si le KI existe déjà, le mettre à jour.

2. Sauvegarde de la Session
```bash
# Sauvegarder l'état actuel pour pouvoir y revenir plus tard
/chat save [nom_de_la_tache_finie]
```

3. Nettoyage et Switch
Choisir l'une des deux options selon le besoin :

**Option A : Continuer dans la même fenêtre (Changement de sujet)**
```bash
# Nettoyer l'historique détaillé tout en gardant les KIs en mémoire
/compress
# Lancer la nouvelle tâche
"Démarrage de la tâche : [Nom de la nouvelle tâche]"
```

**Option B : Reprendre un ancien sujet (Context Swap)**
```bash
# Sauvegarder la session actuelle puis basculer
/chat save [current_task]
/chat resume [old_task_name]
```

4. Validation de la nouvelle isolation
- Vérifier avec `/stats` que le nombre de tokens est redescendu.
- Confirmer que seuls les KIs et le `GEMINI.md` servent de base de départ.

**Focus Chirurgical** : Ce workflow doit être exécuté en moins de 3 échanges pour maximiser l'économie.
