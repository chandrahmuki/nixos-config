-- ~/.config/nvim/lua/core/options.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.clipboard = "unnamedplus"

-- Autoreload settings (for external changes)
vim.opt.autoread = true
vim.opt.updatetime = 300



vim.opt.scrolloff = 7
vim.opt.mouse = ""
vim.opt.cmdheight = 0 -- Hide command line when not used (MuggyVim Premium Style)

-- Render-markdown and general UI settings
vim.opt.conceallevel = 2 -- Hide markdown symbols for a cleaner rendered look
vim.opt.concealcursor = "nc" -- Conceal in Normal and Command mode

vim.opt.signcolumn = "yes"        -- Gutter toujours visible
vim.opt.foldmethod = "expr"       -- Folding via treesitter
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99            -- Tout ouvert par défaut
vim.opt.foldenable = true
vim.opt.swapfile = false          -- Pas de .swp
vim.opt.backup = false            -- Pas de backup
vim.opt.undofile = true           -- Undo persistant
vim.opt.ignorecase = true         -- Search case-insensitive
vim.opt.smartcase = true          -- Sauf si majuscule
vim.opt.wrap = false              -- Pas de wrap
vim.opt.cursorline = true         -- Ligne curseur
