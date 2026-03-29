return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<A-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window Left" },
    { "<A-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window Down" },
    { "<A-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window Up" },
    { "<A-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window Right" },
  },
}
