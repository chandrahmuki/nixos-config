---
Generated: 2026-04-03 12:30 UTC
---

# Learnings & Insights

## Zellij plugin permissions

- Les permissions Zellij sont accordées via le **plugin manager** (`Ctrl+o → p`), pas via un dialog automatique
- Sans `ReadApplicationState` : mode/tabs/session retournent chaîne vide → barre vide
- Sans `RunHostCommand` : git branch ne fonctionne pas
- Les permissions persistent dans `~/.cache/zellij/` — survivent aux `nos` tant que le chemin du WASM est stable
- **Le WASM doit être chargé** pour que le prompt apparaisse → il faut lancer avec le bon layout

## NixOS + Zellij symlinks

- `home.file` crée des symlinks vers le nix store
- `zjstatus.wasm` = symlink vers `/nix/store/HASH/...` → chemin stable côté `~/.config/zellij/plugins/`
- Les permissions sont cachées par chemin de fichier (`file:~/.config/zellij/...`) → stables across rebuilds
- Pas de problème de readonly pour le chargement WASM

## Worktree tmux-modern-tabs

- Avait la bonne config zjstatus mais deux bugs Nix : bloc `programs.zellij` dupliqué + `layouts` n'est pas un attribut valide en HM
- La bonne approche : `home.file.".config/zellij/layouts/dev.kdl".text`

## Persistence Zellij sur NixOS

- La sérialisation native Zellij fonctionne bien pour persist les panes ajoutés manuellement
- Pour le layout initial reproductible → définir dans le KDL Nix
- Pas besoin de systemd service comme pour tmux — `zj` suffit pour l'attach
