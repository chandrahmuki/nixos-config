return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    fzf.setup({
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = { hidden = "nohidden" },
      },
      fzf_colors = true,
    })
  end,
  keys = {
    -- Top Level
    { "<leader><space>", function() require("fzf-lua").files() end, desc = "Find File" },
    { "<leader>,", function() require("fzf-lua").buffers() end, desc = "Switch Buffer" },
    { "<leader>/", function() require("fzf-lua").live_grep() end, desc = "Search" },
    { "<leader>:", function() require("fzf-lua").command_history() end, desc = "Command History" },
    { "<leader>P", function() require("fzf-lua").commands() end, desc = "Command Palette" },
    -- [f]ile
    { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find Files" },
    { "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Recent" },
    { "<leader>fg", function() require("fzf-lua").git_files() end, desc = "Git Files" },
    { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Buffers" },
    -- [g]it
    { "<leader>gs", function() require("fzf-lua").git_status() end, desc = "Git Status" },
    { "<leader>gl", function() require("fzf-lua").git_commits() end, desc = "Git Log" },
    -- [s]earch
    { "<leader>sb", function() require("fzf-lua").blines() end, desc = "Buffer Lines" },
    { "<leader>sg", function() require("fzf-lua").live_grep() end, desc = "Grep" },
    { "<leader>sh", function() require("fzf-lua").help_tags() end, desc = "Help Pages" },
    { "<leader>sk", function() require("fzf-lua").keymaps() end, desc = "Keymaps" },
    { "<leader>sm", function() require("fzf-lua").marks() end, desc = "Marks" },
    { "<leader>sn", function() require("fzf-lua").notifications() end, desc = "Notifications" },
  },
}
