-- Python formatter configuration
-- Supports black and isort with automatic config detection from pyproject.toml

return function()
  -- Helper function to find black executable
  local function find_black(root_dir)
    -- Check for .venv/bin/black first (most common for Poetry projects)
    local venv_black = root_dir .. "/.venv/bin/black"
    if vim.fn.executable(venv_black) == 1 then
      return venv_black
    end

    -- Check if this is a devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      return "devbox"
    end

    -- Check Mason installation
    local mason_black = vim.fn.stdpath "data" .. "/mason/bin/black"
    if vim.fn.executable(mason_black) == 1 then
      return mason_black
    end

    -- Check system installation
    if vim.fn.executable "black" == 1 then
      return "black"
    end

    return nil
  end

  -- Helper function to find isort executable
  local function find_isort(root_dir)
    -- Check for .venv/bin/isort first (most common for Poetry projects)
    local venv_isort = root_dir .. "/.venv/bin/isort"
    if vim.fn.executable(venv_isort) == 1 then
      return venv_isort
    end

    -- Check if this is a devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      return "devbox"
    end

    -- Check Mason installation
    local mason_isort = vim.fn.stdpath "data" .. "/mason/bin/isort"
    if vim.fn.executable(mason_isort) == 1 then
      return mason_isort
    end

    -- Check system installation
    if vim.fn.executable "isort" == 1 then
      return "isort"
    end

    return nil
  end

  -- Custom black formatter with devbox support
  local black_formatter = {
    meta = {
      url = "https://github.com/psf/black",
      description = "The uncompromising Python code formatter",
    },
    options = {
      command = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "pyproject.toml", "setup.py", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local black_cmd = find_black(root_dir)
        if not black_cmd then
          return nil
        end

        -- If we found "devbox", use bash wrapper
        if black_cmd == "devbox" then
          return "bash"
        end

        return black_cmd
      end,
      args = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "pyproject.toml", "setup.py", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local black_cmd = find_black(root_dir)

        -- If using devbox, wrap the command
        if black_cmd == "devbox" then
          return {
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && black --quiet --stdin-filename "$0" -', root_dir),
            "$FILENAME",
          }
        end

        -- Standard black args
        return { "--quiet", "--stdin-filename", "$FILENAME", "-" }
      end,
      cwd = function(_, ctx)
        -- Run in project root so black can find pyproject.toml
        local root_dir = vim.fs.root(ctx.buf, { "pyproject.toml", "setup.py", ".git" })
        return root_dir or vim.fn.getcwd()
      end,
    },
  }

  -- Custom isort formatter with devbox support
  local isort_formatter = {
    meta = {
      url = "https://github.com/PyCQA/isort",
      description = "Python utility / library to sort imports alphabetically and automatically separate them into sections",
    },
    options = {
      command = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "pyproject.toml", "setup.py", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local isort_cmd = find_isort(root_dir)
        if not isort_cmd then
          return nil
        end

        -- If we found "devbox", use bash wrapper
        if isort_cmd == "devbox" then
          return "bash"
        end

        return isort_cmd
      end,
      args = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "pyproject.toml", "setup.py", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local isort_cmd = find_isort(root_dir)

        -- If using devbox, wrap the command
        if isort_cmd == "devbox" then
          return {
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && isort --quiet --filename "$0" -', root_dir),
            "$FILENAME",
          }
        end

        -- Standard isort args
        return { "--quiet", "--filename", "$FILENAME", "-" }
      end,
      cwd = function(_, ctx)
        -- Run in project root so isort can find pyproject.toml
        local root_dir = vim.fs.root(ctx.buf, { "pyproject.toml", "setup.py", ".git" })
        return root_dir or vim.fn.getcwd()
      end,
    },
  }

  return {
    formatters_by_ft = {
      python = { "isort", "black" },
    },
    formatters = {
      black = black_formatter,
      isort = isort_formatter,
    },
  }
end
