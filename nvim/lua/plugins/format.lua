-- Formatting with conform.nvim
-- Uses built-in formatters with notifications for visibility

return {
  "stevearc/conform.nvim",
  dependencies = { "j-hui/fidget.nvim" },
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fc",
      function()
        local conform = require "conform"
        conform.format({ async = true, lsp_fallback = true }, function(err)
          if not err then
            -- Show notification after manual formatting completes
            vim.schedule(function()
              require("plugins.format").notify_formatters()
            end)
          end
        end)
      end,
      mode = "",
      desc = "[F]ormat [C]ode",
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Disable autoformat for files in .git directory
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match "/.git/" then
        return
      end
      return { timeout_ms = 2000, lsp_fallback = true }
    end,
    -- Use built-in formatters - they work with direnv + devbox!
    formatters_by_ft = {
      -- TypeScript/JavaScript
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      -- Ruby
      ruby = { "standardrb" },
      -- Python
      python = { "isort", "black" },
      -- Lua
      lua = { "stylua" },
    },
  },
  config = function(_, opts)
    local conform = require "conform"
    conform.setup(opts)

    -- Helper to find config file for a formatter
    local function find_config_file(formatter_name, root_dir, bufnr)
      local config_files = {
        prettier = { ".prettierrc", ".prettierrc.js", ".prettierrc.json", ".prettierrc.yml", "prettier.config.js" },
        standardrb = { ".standard.yml" },
        black = { "pyproject.toml", "black.toml" },
        isort = { "pyproject.toml", ".isort.cfg", "setup.cfg" },
        stylua = { "stylua.toml", ".stylua.toml" },
      }

      local files = config_files[formatter_name]
      if not files then
        return nil
      end

      local git_root = vim.fs.root(bufnr, { ".git" })
      if not git_root then
        return nil
      end

      -- Search upward from buffer directory for config files
      local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
      for _, file in ipairs(files) do
        -- Search upward, limiting to git root
        local found = vim.fs.find(file, { upward = true, path = buf_dir })
        if found and #found > 0 then
          -- Only accept if within git root
          if found[1]:find("^" .. vim.pesc(git_root)) then
            -- Return relative path from git root
            local rel_path = found[1]:gsub("^" .. vim.pesc(git_root) .. "/", "")
            return rel_path
          end
        end
      end
      return nil
    end

    -- Shared notification function
    local function notify_formatters(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      local formatters = conform.list_formatters(bufnr)
      if #formatters > 0 then
        local root_dir = vim.fs.root(bufnr, { "package.json", ".git", "pyproject.toml", "Gemfile" })
        if root_dir then
          -- Check for config files for each formatter
          local config_info = {}
          for _, formatter in ipairs(formatters) do
            local config = find_config_file(formatter.name, root_dir, bufnr)
            if config then
              table.insert(config_info, string.format("%s (%s)", formatter.name, config))
            else
              table.insert(config_info, formatter.name)
            end
          end

          local ok, fidget = pcall(require, "fidget")
          if ok then
            fidget.notify(string.format("Formatted with: %s", table.concat(config_info, ", ")), vim.log.levels.INFO, { annote = "Format" })
          end
        end
      end
    end

    -- Export for use in keymap
    _G.conform_notify_formatters = notify_formatters

    -- Add notification after format-on-save
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("ConformNotify", { clear = true }),
      callback = function(args)
        -- Only notify if file was actually formatted (not in .git)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        if not bufname:match "/.git/" then
          vim.schedule(function()
            notify_formatters(args.buf)
          end)
        end
      end,
    })
  end,
  -- Export notify function for use in keymap
  notify_formatters = function()
    if _G.conform_notify_formatters then
      _G.conform_notify_formatters()
    end
  end,
}
