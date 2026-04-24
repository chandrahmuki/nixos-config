return {
  "saghen/blink.cmp",
  version = "*",
  dependencies = "rafamadriz/friendly-snippets",
  opts = {
    keymap = { preset = "default" },
    appearance = {
      nerd_font_variant = "mono",
      kind_icons = {
        Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "󰒓",
        Field = "󰜢", Variable = "󰆦", Property = "󰖷", Class = "󰠱",
        Interface = "󰜰", Struct = "󰙅", Module = "󰅩", Unit = "󰑭",
        Value = "󰎠", Enum = "󰕘", Keyword = "󰌋", Snippet = "󰩫",
        Color = "󰏘", File = "󰈙", Reference = "󰈇", Folder = "󰉋",
        EnumMember = "󰕘", Constant = "󰏿", Event = "󰉒", Operator = "󰆕",
        TypeParameter = "󰊄",
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
  opts_extend = { "sources.default" },
}
