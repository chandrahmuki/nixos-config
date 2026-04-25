# Nix Modules — Lessons Learned

- Toujours: `home-manager.users.${username}` pas `david` hardcodé
- Ne jamais modifier `hardware-configuration.nix` (auto-generated)
- Préférer `settings` à `extraConfig` pour HM programs
- Auto-import via `scanModules` → pas besoin d'importer manuellement
