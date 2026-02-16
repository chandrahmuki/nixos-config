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
      mappings = true, -- Réactiver pour autoriser mes icônes manuelles
      rules = false,   -- Désactiver les règles auto qui mettent des "bonbons" (emojis)
    },
    spec = {
      { "<leader>b", group = "buffer", icon = "󰓩 " },
      { "<leader>f", group = "file", icon = "󰈔 " },
      { "<leader>g", group = "git", icon = "󰊢 " },
      { "<leader>q", group = "quit/session", icon = "󰗼 " },
      { "<leader>s", group = "search", icon = " " },
      { "<leader>u", group = "ui", icon = "󰙵 " },
      { "<leader>w", group = "window", icon = "󰖲 " },
      -- Top-level
      { "<leader><space>", icon = " " },
      { "<leader>,",       icon = "󰓩 " },
      { "<leader>.",       icon = "󰉋 " },
      { "<leader>/",       icon = "󰍉 " },
      { "<leader>:",       icon = " " },
      { "<leader>e",       icon = "󰙅 " },
      -- Sous-menus [f]ile
      { "<leader>ff", icon = " " },
      { "<leader>fr", icon = " " },
      { "<leader>fg", icon = "󰊢 " },
      { "<leader>fb", icon = "󰓩 " },
      { "<leader>fe", icon = "󰉋 " },
      { "<leader>fs", icon = "󰆓 " },
      -- Sous-menus [g]it
      { "<leader>gs", icon = "󰊢 " },
      { "<leader>gl", icon = "󰗀 " },
      -- Sous-menus [s]earch
      { "<leader>sn", icon = "󰵙 " },
      { "<leader>sb", icon = "󰈙 " },
      { "<leader>sg", icon = "󰍉 " },
      { "<leader>sh", icon = "󰞋 " },
      { "<leader>sk", icon = "󰌌 " },
      { "<leader>sm", icon = "󰈚 " },
      -- Sous-menus [u]i
      { "<leader>uz", icon = "󰙵 " },
      { "<leader>u.", icon = "󰈚 " },
      { "<leader>uS", icon = "󰒙 " },
    },
  },
  config = function(_, opts)
    require("which-key").setup(opts)
    -- Harmoniser la couleur des groupes (+) avec les descriptions (pas de blanc)
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "WhichKeyDesc" })
  end,
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

