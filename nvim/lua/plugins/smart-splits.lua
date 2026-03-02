return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    require("smart-splits").setup({
      -- Ignorer les conflits avec Zellij, on gère ça via les keymaps Alt+hjkl
      at_edge = "wrap",
    })

    -- Keymaps pour la navigation unifiée
    local map = vim.keymap.set
    map("n", "<A-h>", require("smart-splits").move_cursor_left)
    map("n", "<A-j>", require("smart-splits").move_cursor_down)
    map("n", "<A-k>", require("smart-splits").move_cursor_up)
    map("n", "<A-l>", require("smart-splits").move_cursor_right)
  end,
}
