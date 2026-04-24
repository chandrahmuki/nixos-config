return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 1, -- Set to 1 for perfectly opaque background (no shading)
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
}
