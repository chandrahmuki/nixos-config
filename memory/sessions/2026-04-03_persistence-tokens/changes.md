---
Generated: 2026-04-03 13:15 UTC
---

# Changes Made

## nvim/lua/plugins/persistence.lua (nouveau fichier)
- Plugin `folke/persistence.nvim` via lazy.nvim
- Sessions stockées dans `~/.local/state/nvim/sessions/`
- `need = 1` : sauvegarde si au moins 1 buffer ouvert

## nvim/lua/plugins/whichkey.lua
- Ajouté 4 icônes sous `<leader>q` (groupe "quit/session" existant) :
  - `<leader>qs` 󰆓  Save Session
  - `<leader>ql` 󰦛  Load Session (cwd)
  - `<leader>qL` 󰋚  Load Last Session
  - `<leader>qd` 󰅙  Stop Persistence

## modules/claude.nix (non encore appliqué)
- À faire : ajouter `smallFastModel = "haiku"` pour réduire le coût des tâches légères
