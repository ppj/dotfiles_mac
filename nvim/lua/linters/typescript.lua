-- TypeScript/JavaScript linter configuration
-- Supports ESLint with automatic config detection

return function()
  -- Helper function to find eslint executable
  local function find_eslint(root_dir)
    -- Check for local node_modules installation first (most common)
    local local_eslint = root_dir .. "/node_modules/.bin/eslint"
    if vim.fn.executable(local_eslint) == 1 then
      return local_eslint
    end

    -- Check if this is a devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      -- Return marker that we need to use devbox
      return "devbox"
    end

    -- Check Mason installation
    local mason_eslint = vim.fn.stdpath "data" .. "/mason/bin/eslint"
    if vim.fn.executable(mason_eslint) == 1 then
      return mason_eslint
    end

    -- Check system installation
    if vim.fn.executable "eslint" == 1 then
      return "eslint"
    end

    return nil
  end

  -- Create custom eslint linter with devbox support
  local eslint = {
    cmd = "eslint",
    stdin = true,
    args = {
      "--format",
      "json",
      "--stdin",
      "--stdin-filename",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    },
    stream = "stdout",
    ignore_exitcode = true,
    parser = require("lint.linters.eslint").parser,
  }

  -- Override cmd function to use our custom resolution
  local original_cmd = eslint.cmd
  eslint.cmd = function()
    local root_dir = vim.fs.root(0, { "package.json", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local eslint_cmd = find_eslint(root_dir)
    if not eslint_cmd then
      return original_cmd -- fallback
    end

    -- If devbox project, use bash wrapper
    if eslint_cmd == "devbox" then
      return "bash"
    end

    return eslint_cmd
  end

  -- Override args to support devbox
  local original_args = eslint.args
  eslint.args = function()
    local root_dir = vim.fs.root(0, { "package.json", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local eslint_cmd = find_eslint(root_dir)

    -- If devbox, wrap the command
    if eslint_cmd == "devbox" then
      local filename = vim.api.nvim_buf_get_name(0)
      return {
        "-c",
        string.format('cd "%s" && eval "$(devbox shellenv)" && eslint --format json --stdin --stdin-filename "%s"', root_dir, filename),
      }
    end

    -- Standard eslint args - resolve the function
    local args = {}
    for _, arg in ipairs(original_args) do
      if type(arg) == "function" then
        table.insert(args, arg())
      else
        table.insert(args, arg)
      end
    end
    return args
  end

  return {
    linters_by_ft = {
      javascript = { "eslint" },
      javascriptreact = { "eslint" },
      typescript = { "eslint" },
      typescriptreact = { "eslint" },
    },
    linters = {
      eslint = eslint,
    },
  }
end
