---
Generated: 2026-04-03 11:06 UTC
---

# Configuration Changes

## modules/zellij.nix

- zjstatus : `children` déplacé après le pane (était avant → barre en bas, maintenant → barre en haut)
- Tab Dev avec layout complet :
  ```
  [zjstatus - top]
  [neovim 56% | claude 73%  ]
  [            | terminal 26%]
  [shell bas - 12 lignes     ]
  ```
- cwd="/home/david/nixos-config" sur le tab Dev
- Tab "Monitoring" avec `command="btop"`

## CLAUDE.md

- Section "Session Resume" ajoutée : utiliser `ls -lt sessions/` pour trouver la session la plus récente par mtime, pas l'ordre textuel de index_sessions.md
