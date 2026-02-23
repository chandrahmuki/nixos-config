return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon", -- Vibrant moon style
        transparent = false, -- Opaque as per last test preference
      })
      vim.cmd.colorscheme("tokyonight")
      -- Force Neovim to never show its own default statusline
      vim.opt.laststatus = 0
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    enabled = false, -- User requested to completely remove the bottom status bar
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup()
    end,
  },
}

