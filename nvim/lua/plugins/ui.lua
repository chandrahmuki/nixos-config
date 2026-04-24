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
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Force a single global statusline at the very bottom of the screen
      vim.opt.laststatus = 3
      require("lualine").setup { options = { theme = "tokyonight", globalstatus = true } }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup()
    end,
  },
  -- Diagnostic signs
  {
    dir = vim.fn.stdpath("config"),
    name = "diagnostic-signs",
    config = function()
      local signs = {
        Error = "",
        Warn = "",
        Hint = "",
        Info = "",
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end,
  },
}

