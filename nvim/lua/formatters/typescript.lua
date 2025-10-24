-- TypeScript/JavaScript formatter configuration
-- Supports Prettier with automatic config detection

return function()
  -- Helper function to find prettier executable
  local function find_prettier(root_dir)
    -- Check for local node_modules installation first (most common)
    local local_prettier = root_dir .. "/node_modules/.bin/prettier"
    if vim.fn.executable(local_prettier) == 1 then
      return local_prettier
    end

    -- Check if this is a devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      -- Return shell wrapper that runs prettier in devbox environment
      return "bash"
    end

    -- Check Mason installation
    local mason_prettier = vim.fn.stdpath "data" .. "/mason/bin/prettier"
    if vim.fn.executable(mason_prettier) == 1 then
      return mason_prettier
    end

    -- Check system installation
    if vim.fn.executable "prettier" == 1 then
      return "prettier"
    end

    return nil
  end

  -- Custom prettier formatter with devbox support
  local prettier_formatter = {
    meta = {
      url = "https://github.com/prettier/prettier",
      description = "An opinionated code formatter",
    },
    options = {
      -- Dynamic command resolution
      command = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "package.json", ".prettierrc", ".prettierrc.js", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local prettier_cmd = find_prettier(root_dir)
        if not prettier_cmd then
          return nil
        end

        -- If we found "bash", it means we need to run in devbox environment
        if prettier_cmd == "bash" then
          return prettier_cmd
        end

        return prettier_cmd
      end,
      args = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "package.json", ".prettierrc", ".prettierrc.js", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local prettier_cmd = find_prettier(root_dir)

        -- If using devbox, wrap the command
        if prettier_cmd == "bash" then
          return {
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && prettier --stdin-filepath "$0"', root_dir),
            "$FILENAME",
          }
        end

        -- Standard prettier args
        return { "--stdin-filepath", "$FILENAME" }
      end,
      cwd = function(_, ctx)
        -- Run in project root so prettier can find config files
        local root_dir = vim.fs.root(ctx.buf, { "package.json", ".prettierrc", ".prettierrc.js", ".git" })
        return root_dir or vim.fn.getcwd()
      end,
    },
  }

  return {
    formatters_by_ft = {
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    formatters = {
      prettier = prettier_formatter,
    },
  }
end
