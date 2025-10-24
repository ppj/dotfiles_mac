-- Formatting with conform.nvim
-- Loads modular formatter configurations from lua/formatters/

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format { async = true, lsp_fallback = true }
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = function()
    -- Load individual formatter configurations
    local typescript_config = require "formatters.typescript"()
    local ruby_config = require "formatters.ruby"()
    local python_config = require "formatters.python"()
    local lua_config = require "formatters.lua"()

    -- Merge all formatters_by_ft
    local formatters_by_ft = {}
    for ft, formatters in pairs(typescript_config.formatters_by_ft) do
      formatters_by_ft[ft] = formatters
    end
    for ft, formatters in pairs(ruby_config.formatters_by_ft) do
      formatters_by_ft[ft] = formatters
    end
    for ft, formatters in pairs(python_config.formatters_by_ft) do
      formatters_by_ft[ft] = formatters
    end
    for ft, formatters in pairs(lua_config.formatters_by_ft) do
      formatters_by_ft[ft] = formatters
    end

    -- Merge all custom formatters
    local formatters = {}
    for name, config in pairs(typescript_config.formatters or {}) do
      formatters[name] = config
    end
    for name, config in pairs(ruby_config.formatters or {}) do
      formatters[name] = config
    end
    for name, config in pairs(python_config.formatters or {}) do
      formatters[name] = config
    end
    for name, config in pairs(lua_config.formatters or {}) do
      formatters[name] = config
    end

    return {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable autoformat for files in .git directory
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match "/.git/" then
          return
        end
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
      formatters_by_ft = formatters_by_ft,
      formatters = formatters,
    }
  end,
}
