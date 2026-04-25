# Neovim — Lessons Learned

- 2026-04-24: `nvim-treesitter.configs` n'existe plus dans les versions récentes → `require('nvim-treesitter').setup()`
- 2026-04-24: `blink.cmp` remplace `nvim-cmp` (1 plugin vs 6, 10x plus rapide)
- 2026-04-24: `fzf-lua` > `snacks.picker` (meilleure UX + perf)
- 2026-04-24: Smart-splits/tmux en conflit avec zellij Alt+hjkl → supprimer
- 2026-04-24: Tester plugins avec `NVIM_APPNAME=test nvim` (isolation)
- 2026-04-25: `snacks.explorer` > `mini.files` (standard LazyVim, picker intégré, UI moderne) → garder snacks, drop mini.files
- 2026-04-25: Ne pas supprimer les keymaps lors d'un cleanup sans les migrer → `<leader>e` était mort depuis 1 jour
