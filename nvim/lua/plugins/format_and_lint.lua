return { -- Autoformat
  "stevearc/conform.nvim",
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnum)
      -- Disable autoformat for files being staged in git
      local bufname = vim.api.nvim_buf_get_name(bufnum)
      if bufname:match "/.git//0/" then
        return
      end
      return { timeout_ms = 2000, lsp_fallback = true }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      -- javascript = { { "prettierd", "prettier" } },
      ruby = { "standardrb" },
    },
  },
}
