return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    signs = true,
    keywords = {
      FIX = { icon = "", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = "" },
      HACK = { icon = "" },
      WARN = { icon = "", alt = { "WARNING", "XXX" } },
      PERF = { icon = "", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = "", alt = { "INFO" } },
      TEST = { icon = "", alt = { "TESTING", "PASSED", "FAILED" } },
    },
  },
  keys = {
    { "<leader>st", function() require("todo-comments.fzf")() end, desc = "Search TODOs" },
  },
}
