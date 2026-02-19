---
description: Mise à jour complète de l'index du projet (Repomix). À lancer après des changements structurels majeurs.
---

Ce workflow rafraîchit la "carte" du projet pour que tous les agents aient une vision globale parfaite.

// turbo-all
1. Régénération de l'index Repomix
```bash
repomix --output repomix-nixos-config.md
```

2. Synchronisation Git
```bash
git add repomix-nixos-config.md && git commit -m "chore: update project index (repomix)" && git push
```
