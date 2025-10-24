-- Ruby formatter configuration
-- Supports standardrb with automatic config detection

return function()
  -- Helper function to find standardrb executable
  local function find_standardrb(root_dir)
    -- Check if standardrb is in Gemfile (most common for Ruby projects)
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
    local mason_standardrb = vim.fn.stdpath "data" .. "/mason/bin/standardrb"
    if vim.fn.executable(mason_standardrb) == 1 then
      return mason_standardrb
    end

    if vim.fn.executable "standardrb" == 1 then
      return "standardrb"
    end

    return nil
  end

  -- Custom standardrb formatter with devbox support
  local standardrb_formatter = {
    meta = {
      url = "https://github.com/standardrb/standard",
      description = "Ruby Style Guide, with linter & automatic code fixer",
    },
    options = {
      command = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "Gemfile", ".standard.yml", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local standardrb_cmd = find_standardrb(root_dir)
        if not standardrb_cmd then
          return nil
        end

        -- If we found "devbox" or "bundle", use bash wrapper
        if standardrb_cmd == "devbox" or standardrb_cmd == "bundle" then
          return "bash"
        end

        return standardrb_cmd
      end,
      args = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "Gemfile", ".standard.yml", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local standardrb_cmd = find_standardrb(root_dir)

        -- If using devbox, wrap the command
        if standardrb_cmd == "devbox" then
          return {
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && bundle exec standardrb --fix --format quiet --stderr --stdin "$0"', root_dir),
            "$FILENAME",
          }
        end

        -- If using bundle exec directly
        if standardrb_cmd == "bundle" then
          return {
            "-c",
            string.format('cd "%s" && bundle exec standardrb --fix --format quiet --stderr --stdin "$0"', root_dir),
            "$FILENAME",
          }
        end

        -- Standard standardrb args
        return { "--fix", "--format", "quiet", "--stderr", "--stdin", "$FILENAME" }
      end,
      cwd = function(_, ctx)
        -- Run in project root so standardrb can find .standard.yml
        local root_dir = vim.fs.root(ctx.buf, { "Gemfile", ".standard.yml", ".git" })
        return root_dir or vim.fn.getcwd()
      end,
    },
  }

  return {
    formatters_by_ft = {
      ruby = { "standardrb" },
    },
    formatters = {
      standardrb = standardrb_formatter,
    },
  }
end
