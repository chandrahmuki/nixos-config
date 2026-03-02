-- Recharger automatiquement et silencieusement le fichier s'il change sur le disque
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  pattern = "*",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Notification passive quand un fichier est rechargé (sans prompt bloquant)
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("Fichier synchronisé 📂🔄", vim.log.levels.INFO, { title = "MuggyVim", timeout = 2000 })
  end,
})
