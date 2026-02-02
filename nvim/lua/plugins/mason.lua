return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate", -- met à jour les registres lors de l’install
  config = function()
    require("mason").setup()
  end,
}

