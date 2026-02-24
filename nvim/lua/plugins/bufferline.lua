-- plugins.lua (ou dans ton gestionnaire de plugins Lazy, Packer, etc.)
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "tabs", -- Only show actual tabs (super compact)
          separator_style = "slant", -- Modern slanted separators
          show_buffer_close_icons = false, -- Hide close icons on each buffer
          show_close_icon = false, -- Hide the global close icon
          always_show_bufferline = true, -- Keep it visible
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
