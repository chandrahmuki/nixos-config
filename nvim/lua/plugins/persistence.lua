return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
    need = 1, -- minimum de buffers pour sauvegarder
  },
  keys = {
    { "<leader>qs", function() require("persistence").save() end,              desc = "Save Session" },
    { "<leader>ql", function() require("persistence").load() end,              desc = "Load Session (cwd)" },
    { "<leader>qL", function() require("persistence").load({ last = true }) end, desc = "Load Last Session" },
    { "<leader>qd", function() require("persistence").stop() end,              desc = "Stop Persistence" },
  },
}
