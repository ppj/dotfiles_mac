-- Python linter configuration
-- Supports pylint with automatic config detection from pyproject.toml

return function()
  -- Helper function to find pylint executable
  local function find_pylint(root_dir)
    -- Check for .venv/bin/pylint first (most common for Poetry projects)
    local venv_pylint = root_dir .. "/.venv/bin/pylint"
    if vim.fn.executable(venv_pylint) == 1 then
      return venv_pylint
    end

    -- Check if this is a devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      return "devbox"
    end

    -- Check Mason installation
    local mason_pylint = vim.fn.stdpath "data" .. "/mason/bin/pylint"
    if vim.fn.executable(mason_pylint) == 1 then
      return mason_pylint
    end

    -- Check system installation
    if vim.fn.executable "pylint" == 1 then
      return "pylint"
    end

    return nil
  end

  -- Create custom pylint linter with devbox support
  local pylint = {
    cmd = "pylint",
    stdin = false,
    args = {
      "--output-format",
      "json",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    },
    stream = "stdout",
    ignore_exitcode = true,
    parser = require("lint.linters.pylint").parser,
  }

  -- Override cmd function to use our custom resolution
  pylint.cmd = function()
    local root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local pylint_cmd = find_pylint(root_dir)
    if not pylint_cmd then
      return "pylint" -- fallback
    end

    -- If devbox, use bash wrapper
    if pylint_cmd == "devbox" then
      return "bash"
    end

    return pylint_cmd
  end

  -- Override args to support devbox
  local original_args = pylint.args
  pylint.args = function()
    local root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local pylint_cmd = find_pylint(root_dir)
    local filename = vim.api.nvim_buf_get_name(0)

    -- If using devbox, wrap the command
    if pylint_cmd == "devbox" then
      return {
        "-c",
        string.format('cd "%s" && eval "$(devbox shellenv)" && pylint --output-format json "%s"', root_dir, filename),
      }
    end

    -- Standard pylint args - resolve the function
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
      python = { "pylint" },
    },
    linters = {
      pylint = pylint,
    },
  }
end
