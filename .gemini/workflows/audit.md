---
name: audit
description: Revue de code et conformité (Auditeur).
---

// turbo-all
1. Analyse des changements récents
```bash
git show --stat
```

2. Revue de Code (Skill: `nixos-auditor`)
- Appliquer les contrôles du skill `nixos-auditor`.
- Vérifier les duplications, le style `nix-ld` et les commentaires.
- Lister les optimisations possibles (performance, clarté, sécurité).

3. Conclusion
- Valide la conformité ou propose des correctifs.
- Demande à l'utilisateur de passer à la phase **ARCHIVE** via `/archive` si tout est OK.
- **Focus Chirurgical** : Max 5-10 turns.
