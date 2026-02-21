local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Basic keymaps
map("n", "<leader>qq", ":q<CR>", { desc = "Quit" })
map("n", "<leader>fs", ":w<CR>", { desc = "Save File" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "<leader>s", "<cmd>w<cr>", { desc = "Save File" })

-- Clipboard paste
map("i", "<C-S-v>", '<Esc>"+pa', opts)
map("c", "<C-S-v>", '<C-R>+', opts)


-- Window navigation
map("n", "<leader>wh", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Move to lower window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Move to upper window" })



