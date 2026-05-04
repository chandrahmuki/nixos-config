# Nix Build — Lessons Learned

- 2026-04-24: `nix eval` avant de dire "c'est bon"
- 2026-05-04: Overlay `doCheck = false` peut invalider le cache binaire (deno) — préférer supprimer l'override
- 2026-04-03: Overlay `doCheck = false` pour contourner tests cassés (openldap)
- 2026-04-03: `pkgs-master` pour packages non dans unstable (claude-code)
- 2026-04-03: Warning `'system' renamed` = vient des inputs, pas config
