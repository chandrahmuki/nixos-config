return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      -- mini.pairs (auto-pairs)
      require("mini.pairs").setup()

      -- mini.comment (toggle comment)
      require("mini.comment").setup()
    end,
  }
}
