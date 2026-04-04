---
Generated: 2026-04-03 UTC
---

# Decisions

### Pattern Dendritic : config actuelle suffisante
**Pourquoi :** flake-parts utile surtout pour multi-hosts/multi-users. Un seul host/user → overhead inutile.
**Impact :** pas de migration vers flake-parts prévue.

### Index projet style ai-codex plutôt que RAG
**Pourquoi :** RAG over-engineered pour ~40 fichiers. Index statique + index manuel = moins cher, plus prévisible.
**Impact :** `project_map.md` lu en ~1150 tokens au lieu de scanner le repo.

### Pas de PRs GitHub dans les snapshots
**Pourquoi :** config perso = push direct sur main, pas de PRs. `git log` suffit.
**Impact :** snapshot capture git log --oneline -20 + historique conversation.

### Backlog séparé des sessions
**Pourquoi :** les TODOs sans urgence se perdent dans les session snapshots.
**Impact :** `memory/backlog.md` créé comme fichier persistant.
