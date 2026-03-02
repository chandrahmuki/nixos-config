-- MuggyVim 🚀
-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- core
require("core")

-- setup lazy
require("lazy").setup("plugins", {
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})

-- load user overrides
pcall(require, "custom")

vim.notify("Welcome to MuggyVim ✨", vim.log.levels.INFO)

