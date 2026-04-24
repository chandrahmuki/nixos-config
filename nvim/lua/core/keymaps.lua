local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Basic keymaps
map("n", "<leader>qq", ":q<CR>", { desc = "Quit" })
map("n", "<leader>qa", ":qa!<CR>", { desc = "Quit All (Force)" })
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

-- Window splits (independent views)
map("n", "<leader>w-", "<cmd>split<cr>", { desc = "Split Horizontal" })
map("n", "<leader>w|", "<cmd>vsplit<cr>", { desc = "Split Vertical" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close Split" })
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Keep Only This Split" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear Search" })

-- Better window resize
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Resize +2" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Resize -2" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "V-Resize -2" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "V-Resize +2" })

-- Keep cursor centered on scroll
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })



