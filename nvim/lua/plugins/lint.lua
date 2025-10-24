-- Linting with nvim-lint
-- Uses built-in linters with notifications for visibility

return {
  "mfussenegger/nvim-lint",
  dependencies = { "j-hui/fidget.nvim" },
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require "lint"

    -- Helper to find config file for a linter and return relative path from git root
    local function find_config_file(linter_name, root_dir, bufnr)
      local config_files = {
        eslint = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yml", ".eslintrc.yaml", "eslint.config.js" },
        rubocop = { ".rubocop.yml" },
        pylint = { "pyproject.toml", ".pylintrc", "pylintrc" },
      }

      local files = config_files[linter_name]
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

    -- Use built-in linters - they work with direnv + devbox!
    lint.linters_by_ft = {
      -- TypeScript/JavaScript
      javascript = { "eslint" },
      javascriptreact = { "eslint" },
      typescript = { "eslint" },
      typescriptreact = { "eslint" },
      -- Ruby
      ruby = { "rubocop" },
      -- Python
      python = { "pylint" },
    }

    -- Set up autocommands to trigger linting
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- Lint on all these events (includes BufEnter for initial diagnostics)
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

    -- Show notification only on save
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if vim.bo.modifiable and not bufname:match "/.git/" then
          vim.schedule(function()
            local ft = vim.bo.filetype
            local linters = lint.linters_by_ft[ft]
            if linters and #linters > 0 then
              -- Find root directory and config files
              local root_dir = vim.fs.root(0, { "package.json", ".git", "pyproject.toml", "Gemfile" })
              if root_dir then
                -- Check for config files for each linter
                local config_info = {}
                for _, linter_name in ipairs(linters) do
                  local config = find_config_file(linter_name, root_dir, 0)
                  if config then
                    table.insert(config_info, string.format("%s (%s)", linter_name, config))
                  else
                    table.insert(config_info, linter_name)
                  end
                end

                local ok, fidget = pcall(require, "fidget")
                if ok then
                  fidget.notify(string.format("Linted with: %s", table.concat(config_info, ", ")), vim.log.levels.INFO, { annote = "Lint" })
                end
              end
            end
          end)
        end
      end,
    })
  end,
}
