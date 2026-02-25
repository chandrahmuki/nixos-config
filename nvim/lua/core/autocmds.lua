-- Recharger automatiquement le fichier s'il change sur le disque
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained", "BufEnter" }, {
  pattern = "*",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Notification quand un fichier est rechargé
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("Fichier rechargé (modifié sur le disque) 📂🔄", vim.log.levels.INFO)
  end,
})
