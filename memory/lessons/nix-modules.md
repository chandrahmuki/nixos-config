# Nix Modules — Lessons Learned

- Toujours: `home-manager.users.${username}` pas `david` hardcodé
- Ne jamais modifier `hardware-configuration.nix` (auto-generated)
- 2026-05-04: HM module (programs.*) gère default browser + policies → pas de redondance xdg manuelle
- Préférer `settings` à `extraConfig` pour HM programs
- Auto-import via `scanModules` → pas besoin d'importer manuellement
- 2026-05-12: Pour un layout zellij sans cwd fixe, omettre `cwd` dans le tab → utilise le répertoire courant
- 2026-05-12: Plusieurs alias possibles pour un même programme → `zellnix` fixe vs `zelldev` flexible
