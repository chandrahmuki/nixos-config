return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      -- mini.files (explorer)
      local minifiles = require("mini.files")
      local function go_in_and_close()
        local entry = minifiles.get_fs_entry()
        if entry and entry.fs_type == "file" then
          minifiles.go_in()
          minifiles.close()
        else
          minifiles.go_in()
        end
      end
      minifiles.setup({
        mappings = {
          close = "q",
          go_in = "l",
          go_in_plus = "L",
          go_out = "h",
          go_out_plus = "H",
          reset_cursor = "<C-o>",
          reveal_cwd = "@",
          show_cwd = "g.",
          synchronize = "=",
          toggle_preview = "P",
        },
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowOpen",
        callback = function(args)
          local buf_id = vim.api.nvim_win_get_buf(args.data.win_id)
          vim.keymap.set("n", "<CR>", go_in_and_close, { buffer = buf_id, desc = "mini.files: open and close" })
        end,
      })

      -- mini.pairs (auto-pairs)
      require("mini.pairs").setup()

      -- mini.comment (toggle comment)
      require("mini.comment").setup()
    end,
  }
}
