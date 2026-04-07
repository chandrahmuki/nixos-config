return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.files").setup({
        mappings = {
          close = "q",
          go_in = { "l", "<CR>" },
          go_in_plus = "L",
          go_out = { "h", "<BS>" },
          go_out_plus = "H",
          reset_cursor = "<C-o>",
          reveal_cwd = "@",
          show_cwd = "g.",
          synchronize = "=",
          toggle_preview = "P",
        },
        options = {
          use_as_default_explorer = true,
        },
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferOpen",
        callback = function(args)
          local buf = args.data.buf_id
          vim.keymap.set("n", "<CR>", function()
            vim.cmd("normal! l")
            require("mini.files").close()
          end, { buffer = buf, nowait = true })
          vim.keymap.set("n", "l", function()
            vim.cmd("normal! l")
            require("mini.files").close()
          end, { buffer = buf, nowait = true })
        end,
      })
    end,
  }
}
