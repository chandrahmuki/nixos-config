-- plugins.lua (ou dans ton gestionnaire de plugins Lazy, Packer, etc.)
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", -- ou "tabs"
          separator_style = "slant", -- "slant", "thick", "thin", etc.
          diagnostics = "nvim_lsp", -- affiche les erreurs LSP
          show_buffer_close_icons = true,
          show_close_icon = false,
        },
      })

  -- 🔹 Raccourcis
      vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
      vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
      vim.keymap.set("n", "<leader>bc", "<Cmd>bdelete<CR>", { desc = "Close buffer" })
      vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })

    end,
  }
}
