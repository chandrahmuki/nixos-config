return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      -- Nix (using nixd for better docs/completion)
      vim.lsp.enable("nixd")
      vim.lsp.config("nixd", {
        capabilities = capabilities,
        settings = {
          nixd = {
            nixpkgs = {
              expr = "import (builtins.getFlake \"/home/david/nixos-config\").inputs.nixpkgs { }",
            },
            formatting = {
              command = { "nixfmt" },
            },
            options = {
              nixos = {
                expr = "(builtins.getFlake \"/home/david/nixos-config\").nixosConfigurations.muggy-nixos.options",
              },
              home_manager = {
                expr = "(builtins.getFlake \"/home/david/nixos-config\").nixosConfigurations.muggy-nixos.options.home-manager.users.type.getSubOptions [ ]",
              },
            },
          },
        },
      })

      -- Lua
      vim.lsp.enable("lua_ls")
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
    end,
  },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
}

