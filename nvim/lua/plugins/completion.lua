return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim", -- icônes
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text", -- montre icône + texte
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip", priority = 800 },
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      -- complétion pour / ? (recherche)
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- complétion pour :
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
            -- ========================
      -- Couleurs Nord pour nvim-cmp
      -- ========================
      local set_hl = vim.api.nvim_set_hl
      set_hl(0, "CmpItemAbbr", { fg = "#D8DEE9" })
      set_hl(0, "CmpItemAbbrMatch", { fg = "#88C0D0", bold = true })
      set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#88C0D0", bold = true })
      set_hl(0, "CmpItemMenu", { fg = "#616E88" })

      -- par kind
      set_hl(0, "CmpItemKindFunction", { fg = "#88C0D0" }) -- bleu clair
      set_hl(0, "CmpItemKindMethod",   { fg = "#88C0D0" })
      set_hl(0, "CmpItemKindKeyword",  { fg = "#81A1C1" }) -- bleu foncé
      set_hl(0, "CmpItemKindVariable", { fg = "#EBCB8B" }) -- jaune
      set_hl(0, "CmpItemKindField",    { fg = "#EBCB8B" })
      set_hl(0, "CmpItemKindProperty", { fg = "#EBCB8B" })
      set_hl(0, "CmpItemKindSnippet",  { fg = "#A3BE8C" }) -- vert
      set_hl(0, "CmpItemKindClass",    { fg = "#D08770" }) -- orange
      set_hl(0, "CmpItemKindInterface",{ fg = "#B48EAD" }) -- violet
    end,
  },
}

