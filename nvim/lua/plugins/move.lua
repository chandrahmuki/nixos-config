return {
  "fedepujol/move.nvim",
  keys = {
    -- Normal Mode
    { "<S-j>", ":MoveLine(1)<CR>", desc = "Move Line Down" },
    { "<S-k>", ":MoveLine(-1)<CR>", desc = "Move Line Up" },
    { "<S-h>", ":MoveHChar(-1)<CR>", desc = "Move Character Left" },
    { "<S-l>", ":MoveHChar(1)<CR>", desc = "Move Character Right" },
    { "<leader>wb>", ":MoveWord(1)<CR>", mode = { "n" }, desc = "Move Word Right" },
    { "<leader>wf>", ":MoveWord(-1)<CR>", mode = { "n" }, desc = "Move Word Left" },
    -- Visual Mode
    { "<S-j>", ":MoveBlock(1)<CR>", mode = { "v" }, desc = "Move Block Down" },
    { "<S-k>", ":MoveBlock(-1)<CR>", mode = { "v" }, desc = "Move Block Up" },
    { "<S-h>", ":MoveHBlock(-1)<CR>", mode = { "v" }, desc = "Move Block Left" },
    { "<S-l>", ":MoveHBlock(1)<CR>", mode = { "v" }, desc = "Move Block Right" },
  },
  opts = {},
}
