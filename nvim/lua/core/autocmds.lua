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

-- Formatage automatique à la sauvegarde (tous les fichiers avec LSP)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    local bufnr = args.buf
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients > 0 then
      vim.lsp.buf.format({ async = false, bufnr = bufnr })
    end
  end,
})

-- Highlight du texte yanké (flash visuel)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Retour à la ligne douce (conserver indent)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "nix", "lua", "rust", "markdown" },
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
