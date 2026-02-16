return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    spec = {
      { "<leader>f", group = "file / find", icon = "󰈔" },
      { "<leader>g", group = "git", icon = "󰊢" },
      { "<leader>s", group = "search", icon = "" },
      { "<leader>b", group = "buffer", icon = "󰓩" },
      { "<leader>u", group = "ui / util", icon = "󰙵" },
      { "<leader>w", group = "window", icon = "󰖲" },
      { "<leader>q", group = "quit / session", icon = "󰗼" },
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

