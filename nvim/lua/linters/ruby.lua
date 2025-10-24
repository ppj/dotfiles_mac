-- Ruby linter configuration
-- Supports rubocop and standard with automatic config detection

return function()
  -- Helper function to find rubocop executable
  local function find_rubocop(root_dir)
    -- Check if rubocop is in Gemfile (most common for Ruby projects)
    local has_gemfile = vim.fn.filereadable(root_dir .. "/Gemfile") == 1
    if has_gemfile then
      if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
        -- Devbox project: run bundle exec within devbox shell environment
        return "devbox"
      else
        -- Not a devbox project: use bundle exec directly
        return "bundle"
      end
    end

    -- No Gemfile - check for Mason or system installation
    local mason_rubocop = vim.fn.stdpath "data" .. "/mason/bin/rubocop"
    if vim.fn.executable(mason_rubocop) == 1 then
      return mason_rubocop
    end

    if vim.fn.executable "rubocop" == 1 then
      return "rubocop"
    end

    return nil
  end

  -- Helper function to find standard executable
  local function find_standard(root_dir)
    -- Check if standard is in Gemfile (most common for Ruby projects)
    local has_gemfile = vim.fn.filereadable(root_dir .. "/Gemfile") == 1
    if has_gemfile then
      if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
        -- Devbox project: run bundle exec within devbox shell environment
        return "devbox"
      else
        -- Not a devbox project: use bundle exec directly
        return "bundle"
      end
    end

    -- No Gemfile - check for Mason or system installation
    local mason_standard = vim.fn.stdpath "data" .. "/mason/bin/standardrb"
    if vim.fn.executable(mason_standard) == 1 then
      return mason_standard
    end

    if vim.fn.executable "standardrb" == 1 then
      return "standardrb"
    end

    return nil
  end

  -- Create custom rubocop linter with devbox support
  local rubocop = {
    cmd = "rubocop",
    stdin = true,
    args = {
      "--format",
      "json",
      "--force-exclusion",
      "--stdin",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    },
    stream = "stdout",
    ignore_exitcode = true,
    parser = require("lint.linters.rubocop").parser,
  }

  -- Override cmd function to use our custom resolution
  rubocop.cmd = function()
    local root_dir = vim.fs.root(0, { "Gemfile", ".rubocop.yml", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local rubocop_cmd = find_rubocop(root_dir)
    if not rubocop_cmd then
      return "rubocop" -- fallback
    end

    -- If devbox or bundle, use bash wrapper
    if rubocop_cmd == "devbox" or rubocop_cmd == "bundle" then
      return "bash"
    end

    return rubocop_cmd
  end

  -- Override args to support devbox
  local original_args = rubocop.args
  rubocop.args = function()
    local root_dir = vim.fs.root(0, { "Gemfile", ".rubocop.yml", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local rubocop_cmd = find_rubocop(root_dir)
    local filename = vim.api.nvim_buf_get_name(0)

    -- If using devbox, wrap the command
    if rubocop_cmd == "devbox" then
      return {
        "-c",
        string.format('cd "%s" && eval "$(devbox shellenv)" && bundle exec rubocop --format json --force-exclusion --stdin "%s"', root_dir, filename),
      }
    end

    -- If using bundle exec directly
    if rubocop_cmd == "bundle" then
      return {
        "-c",
        string.format('cd "%s" && bundle exec rubocop --format json --force-exclusion --stdin "%s"', root_dir, filename),
      }
    end

    -- Standard rubocop args - resolve the function
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
      ruby = { "rubocop" },
    },
    linters = {
      rubocop = rubocop,
    },
  }
end
