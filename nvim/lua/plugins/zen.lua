return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        width = 120, -- width of the Zen window
        height = 1, -- height of the Zen window
        options = {
          signcolumn = "no", -- disable signcolumn
          number = false, -- disable number column
          relativenumber = false, -- disable relative number column
          cursorline = false, -- disable cursorline
          cursorcolumn = false, -- disable cursor column
          foldcolumn = "0", -- disable fold column
          list = false, -- disable whitespace characters
          showcmd = false, -- hide command line (bottom right)
          ruler = false, -- hide ruler (43,1 35%)
          laststatus = 0, -- hide status line
          showmode = false, -- hide -- INSERT -- etc
        },
      },
      plugins = {
        options = {
          enabled = true,
          runtimepath = true, -- for local plugins
          filetype = true, -- for filetype options
        },
        twilight = { enabled = true }, -- enable twilight when zen mode is active
        gitsigns = { enabled = false },
        tmux = { enabled = false },
      },
      on_open = function(win) end,
      on_close = function() end,
    },
    keys = {
      { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
  },
  {
    "folke/twilight.nvim",
    opts = {
      dimming = {
        alpha = 0.25, -- amount of dimming
        color = { "Normal", "#ffffff" },
        term_bg = "#000000", -- if GUIs use g:terminal_color_0
        inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
      },
      context = 10, -- amount of lines we will try to show around the current line
      treesitter = true, -- use treesitter when available for the notifications code window
      expand = { -- for treesitter, we we always try to expand to the children of the current node
        "function",
        "method",
        "table",
        "if_statement",
      },
      exclude = {}, -- exclude these filetypes
    },
  },
}
