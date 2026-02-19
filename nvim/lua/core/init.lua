-- ~/.config/nvim/lua/core/init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")
require("core.keymaps")
-- ~/.config/nvim/lua/core/autocmds.lua

-- Recharger automatiquement le fichier s'il change sur le disque
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})
