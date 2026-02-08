---
description: [MISSION AUDIT] Analyse du dernier commit pour revue de code et conformité.
---

// turbo-all
1. Analyse des changements récents
```bash
git show --stat
```

2. Revue de Code
- Compare le code avec les règles de `GEMINI.md`.
- Vérifie la cohérence de l'architecture NixOS.
- Liste les optimisations possibles (performance, clarté, sécurité).

3. Conclusion
- Valide la conformité ou propose des correctifs.
- Demande à l'utilisateur de passer à la phase **ARCHIVE** via `/archive` si tout est OK.
- **Focus Chirurgical** : Max 5-10 turns.
