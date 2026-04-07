return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.files").setup({
        mappings = {
          close = "q",
          go_in = "l",
          go_in_plus = "L",
          go_out = "h",
          go_out_plus = "H",
          reset_cursor = "<C-o>",
          reveal_cwd = "@",
          show_cwd = "g.",
          synchronize = "=",
          toggle_preview = "P",
        },
      })
    end,
  }
}
