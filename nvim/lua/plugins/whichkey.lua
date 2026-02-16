return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "classic",
    win = {
      border = "none",
      padding = { 1, 2 },
    },
    layout = {
      spacing = 3,
      align = "center",
    },
    icons = {
      separator = "➜",
      group = "+",
    },
    spec = {
      { "<leader>b", group = "buffer", icon = "󰓩" },
      { "<leader>f", group = "file", icon = "󰈔" },
      { "<leader>g", group = "git", icon = "󰊢" },
      { "<leader>q", group = "quit/session", icon = "󰗼" },
      { "<leader>s", group = "search", icon = "" },
      { "<leader>u", group = "ui", icon = "󰙵" },
      { "<leader>w", group = "window", icon = "󰖲" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}

