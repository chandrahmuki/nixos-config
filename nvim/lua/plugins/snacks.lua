return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
███╗   ███╗██╗   ██╗ ██████╗  ██████╗ ██╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗ ████║██║   ██║██╔════╝ ██╔════╝ ╚██╗ ██╔╝██║   ██║██║████╗ ████║
██╔████╔██║██║   ██║██║  ███╗██║  ███╗  ████╔╝ ██║   ██║██║██╔████╔██║
██║╚██╔╝██║██║   ██║██║   ██║██║   ██║  ╚██╔╝  ██║   ██║██║██║╚██╔╝██║
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝╚██████╔╝   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝     ╚═╝ ╚═════╝  ╚═════╝  ╚═════╝    ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝

                        ✨ Welcome to MuggyVim ✨
        ]],
      },
    },
    explorer = {
      enabled = true,
      replace = {
        ["nvim-tree"] = true,
      },
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          layout = { preset = "dropdown", preview = false },
          auto_close = true,
          jump = { close = true },
        },
      },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>E", function() Snacks.explorer({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Explorer (Current Dir)" },
    { "<leader>u.", function() Snacks.scratch() end, desc = "Scratch Buffer" },
    { "<leader>uS", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
  },
}

