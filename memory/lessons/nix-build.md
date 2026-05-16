# Nix Build — Lessons Learned

- 2026-04-24: `nix eval` avant de dire "c'est bon"
- 2026-05-04: Overlay `doCheck = false` peut invalider le cache binaire (deno) — préférer supprimer l'override
- 2026-04-03: Overlay `doCheck = false` pour contourner tests cassés (openldap)
- 2026-04-03: `pkgs-master` pour packages non dans unstable (claude-code)
- 2026-04-03: Warning `'system' renamed` = vient des inputs, pas config
- 2026-05-16: `buildNpmPackage` npmDepsFetcherVersion v2 nécessite integrity hashes sur TOUS les packages du workspace
- 2026-05-16: Binaire Bun compilé a besoin de theme/, assets/ à côté du binaire (PI_PACKAGE_DIR), pas dans share/
- 2026-05-16: `npmWorkspace` casse les builds monorepo quand les deps référencent des packages siblings
- 2026-05-16: `PI_SKIP_VERSION_CHECK=1` dans wrapper pour éviter comparaison contre API upstream
- 2026-05-16: sops CLI nécessite clé age convertie depuis SSH (`ssh-to-age -private-key`) via SOPS_AGE_KEY
