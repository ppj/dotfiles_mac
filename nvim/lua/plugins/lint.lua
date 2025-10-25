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
      -- Search for ALL config files at once to find the closest match
      local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
      local found = vim.fs.find(files, { upward = true, path = buf_dir, limit = 1 })
      if found and #found > 0 then
        -- Only accept if within git root
        if found[1]:find("^" .. vim.pesc(git_root)) then
          -- Return relative path from git root
          local rel_path = found[1]:gsub("^" .. vim.pesc(git_root) .. "/", "")
          return rel_path
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

    -- Configure linters to find local/project-specific installations
    -- This handles cases where subdirectories have their own package managers

    -- ESLint: Check for local node_modules installation
    local eslint = lint.linters.eslint
    eslint.cmd = function()
      local root_dir = vim.fs.root(0, { "package.json", ".git" })
      if root_dir then
        local local_eslint = root_dir .. "/node_modules/.bin/eslint"
        if vim.fn.executable(local_eslint) == 1 then
          return local_eslint
        end
      end
      return "eslint" -- fallback to PATH
    end

    -- Pylint: Check for .venv installation
    local pylint = lint.linters.pylint
    pylint.cmd = function()
      local root_dir = vim.fs.root(0, { "pyproject.toml", ".git" })
      if root_dir then
        local venv_pylint = root_dir .. "/.venv/bin/pylint"
        if vim.fn.executable(venv_pylint) == 1 then
          return venv_pylint
        end
      end
      return "pylint" -- fallback to PATH
    end

    -- Rubocop: Use bundle exec if Gemfile exists
    local rubocop = lint.linters.rubocop
    rubocop.cmd = function()
      local root_dir = vim.fs.root(0, { "Gemfile", ".git" })
      if root_dir and vim.fn.filereadable(root_dir .. "/Gemfile") == 1 then
        return "bundle"
      end
      return "rubocop" -- fallback to PATH
    end
    rubocop.args = function()
      local root_dir = vim.fs.root(0, { "Gemfile", ".git" })
      if root_dir and vim.fn.filereadable(root_dir .. "/Gemfile") == 1 then
        return { "exec", "rubocop", "--format", "json", "--force-exclusion", "--stdin" }
      end
      return { "--format", "json", "--force-exclusion", "--stdin" }
    end

    -- Helper to check if file should be linted
    local function should_lint_file(bufname)
      if not vim.bo.modifiable or bufname:match "/.git/" then
        return false
      end
      -- Skip config files that are typically ignored by linters
      local filename = vim.fn.fnamemodify(bufname, ":t")
      local skip_patterns = {
        "^%.eslintrc", -- .eslintrc, .eslintrc.js, .eslintrc.json, etc.
        "^eslint%.config%.", -- eslint.config.js, eslint.config.mjs, etc.
        "^%.prettierrc", -- .prettierrc, .prettierrc.js, etc.
        "^prettier%.config%.", -- prettier.config.js, etc.
        "^jest%.config%.", -- jest.config.js, etc.
        "^%.rubocop%.yml$", -- .rubocop.yml
        "^%.pylintrc$", -- .pylintrc
        "^pylintrc$", -- pylintrc
      }
      for _, pattern in ipairs(skip_patterns) do
        if filename:match(pattern) then
          return false
        end
      end
      return true
    end

    -- Set up autocommands to trigger linting
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- Lint on all these events (includes BufEnter for initial diagnostics)
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if should_lint_file(bufname) then
          -- Check if any configured linters are actually available
          local ft = vim.bo.filetype
          local linters = lint.linters_by_ft[ft]
          if linters and #linters > 0 then
            local available_linters = {}
            for _, linter_name in ipairs(linters) do
              local linter = lint.linters[linter_name]
              if linter then
                local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
                if vim.fn.executable(cmd) == 1 then
                  table.insert(available_linters, linter_name)
                end
              end
            end
            -- Only try to lint if at least one linter is available
            if #available_linters > 0 then
              lint.try_lint(available_linters)
            end
          end
        end
      end,
    })

    -- Show notification only on save
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if should_lint_file(bufname) then
          vim.schedule(function()
            local ft = vim.bo.filetype
            local linters = lint.linters_by_ft[ft]
            if linters and #linters > 0 then
              -- Check which linters are actually available
              local available_linters = {}
              for _, linter_name in ipairs(linters) do
                local linter = lint.linters[linter_name]
                if linter then
                  local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
                  if vim.fn.executable(cmd) == 1 then
                    table.insert(available_linters, linter_name)
                  end
                end
              end

              local ok, fidget = pcall(require, "fidget")
              if ok then
                if #available_linters > 0 then
                  -- Find root directory and config files for available linters
                  local root_dir = vim.fs.root(0, { "package.json", ".git", "pyproject.toml", "Gemfile" })
                  if root_dir then
                    local config_info = {}
                    for _, linter_name in ipairs(available_linters) do
                      local config = find_config_file(linter_name, root_dir, 0)
                      if config then
                        table.insert(config_info, string.format("%s (≈ %s)", linter_name, config))
                      else
                        table.insert(config_info, linter_name)
                      end
                    end
                    fidget.notify(string.format("Linted with: %s", table.concat(config_info, ", ")), vim.log.levels.INFO, { annote = "Lint" })
                  end
                else
                  -- No linters found
                  fidget.notify("Linting skipped (linter not found)", vim.log.levels.WARN, { annote = "Lint" })
                end
              end
            end
          end)
        end
      end,
    })
  end,
}
