-- ~/.config/nvim/lua/core/autocmds.lua

-- Recharger automatiquement le fichier s'il change sur le disque
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})
