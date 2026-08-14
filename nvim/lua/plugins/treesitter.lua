return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "nix", "lua", "rust", "markdown", "markdown_inline",
        "bash", "json", "toml", "yaml", "regex", "vim", "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
