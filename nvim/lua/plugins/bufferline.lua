-- plugins.lua (ou dans ton gestionnaire de plugins Lazy, Packer, etc.)
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", -- Back to buffers so you can see all your files!
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
          always_show_bufferline = true,
          -- Ultra-compact settings --
          max_name_length = 15,
          tab_size = 15,
          diagnostics = false, -- Remove diagnostics to save space
          show_tab_indicators = false,
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
