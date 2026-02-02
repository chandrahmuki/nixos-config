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
████╗ ████║██║   ██║██╔═══██╗██╔═══██╗██║   ██║██║   ██║██║████╗ ████║
██╔████╔██║██║   ██║██║   ██║██║   ██║██║   ██║██║   ██║██║██╔████╔██║
██║╚██╔╝██║██║   ██║██║   ██║██║   ██║╚██╗ ██╔╝╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝╚██████╔╝ ╚████╔╝  ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝     ╚═╝ ╚═════╝  ╚═════╝  ╚═════╝   ╚═══╝    ╚═══╝  ╚═╝╚═╝     ╚═╝
                        ✨ Welcome to MuggyVim ✨
        ]],
      },
    },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>,",       function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/",       function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>:",       function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>e",       function() Snacks.explorer() end, desc = "File Explorer" },

    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },

    -- git
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },

    -- search
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },

    -- Other
    { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<c-/>",     function() Snacks.terminal() end, desc = "Toggle Terminal" },
  },
}

