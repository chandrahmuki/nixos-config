# Nix Modules — Lessons Learned

- Toujours: `home-manager.users.${username}` pas `david` hardcodé
- Ne jamais modifier `hardware-configuration.nix` (auto-generated)
- 2026-05-04: HM module (programs.*) gère default browser + policies → pas de redondance xdg manuelle
- Préférer `settings` à `extraConfig` pour HM programs
- Auto-import via `scanModules` → pas besoin d'importer manuellement
