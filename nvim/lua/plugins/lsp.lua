return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 4 },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      -- Nix (using nixd for better docs/completion)
      vim.lsp.enable("nixd")
      local config_directory = vim.env.NIXOS_CONFIG_DIR or "/etc/nixos"
      local hostname = vim.env.NIXOS_CONFIG_HOST or "nixos"
      vim.lsp.config("nixd", {
        capabilities = capabilities,
        settings = {
          nixd = {
            nixpkgs = {
              expr = "import <nixpkgs> { }",
            },
            formatting = {
              command = { "nixfmt" },
            },
            options = {
              nixos = {
                expr = string.format("(builtins.getFlake \"%s\").nixosConfigurations.%s.options", config_directory, hostname),
              },
              ["home-manager"] = {
                expr = string.format("(builtins.getFlake \"%s\").nixosConfigurations.%s.options.home-manager.users.type.getSubOptions [ ]", config_directory, hostname),
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
