-- Linting with nvim-lint
-- Loads modular linter configurations from lua/linters/

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require "lint"

    -- Load individual linter configurations
    local typescript_config = require "linters.typescript"()
    local ruby_config = require "linters.ruby"()
    local python_config = require "linters.python"()

    -- Merge all linters_by_ft
    local linters_by_ft = {}
    for ft, linters in pairs(typescript_config.linters_by_ft) do
      linters_by_ft[ft] = linters
    end
    for ft, linters in pairs(ruby_config.linters_by_ft) do
      linters_by_ft[ft] = linters
    end
    for ft, linters in pairs(python_config.linters_by_ft) do
      linters_by_ft[ft] = linters
    end

    -- Merge all custom linters
    for name, config in pairs(typescript_config.linters or {}) do
      lint.linters[name] = config
    end
    for name, config in pairs(ruby_config.linters or {}) do
      lint.linters[name] = config
    end
    for name, config in pairs(python_config.linters or {}) do
      lint.linters[name] = config
    end

    lint.linters_by_ft = linters_by_ft

    -- Set up autocommands to trigger linting
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        -- Only lint if the buffer is modifiable and not in .git directory
        local bufname = vim.api.nvim_buf_get_name(0)
        if vim.bo.modifiable and not bufname:match "/.git/" then
          lint.try_lint()
        end
      end,
    })
  end,
}
