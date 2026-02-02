local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Basic keymaps
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>w", ":w<CR>", { desc = "Save" })

-- Clipboard paste
map("i", "<C-S-v>", '<Esc>"+pa', opts)
map("c", "<C-S-v>", '<C-R>+', opts)


-- Window navigation
map("n", "<leader>h", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>l", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>j", "<C-w>j", { desc = "Move to lower window" })
map("n", "<leader>k", "<C-w>k", { desc = "Move to upper window" })



