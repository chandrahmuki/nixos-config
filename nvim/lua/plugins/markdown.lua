return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown", "norg", "rmd", "org" },
  opts = {
    anti_conceal = {
      enabled = false, -- Stop the "blinking" flicker when moving cursor
    },
    render_modes = { "n", "c" }, -- Only render in Normal and Command mode, keep raw markdown in Insert
    heading = {
      sign = false,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
  },
}
