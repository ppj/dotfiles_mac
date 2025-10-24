-- Lua formatter configuration
-- Supports stylua with automatic config detection

return function()
  -- Helper function to find stylua executable
  local function find_stylua(root_dir)
    -- Check if this is a devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      return "devbox"
    end

    -- Check Mason installation
    local mason_stylua = vim.fn.stdpath "data" .. "/mason/bin/stylua"
    if vim.fn.executable(mason_stylua) == 1 then
      return mason_stylua
    end

    -- Check system installation
    if vim.fn.executable "stylua" == 1 then
      return "stylua"
    end

    return nil
  end

  -- Custom stylua formatter with devbox support
  local stylua_formatter = {
    meta = {
      url = "https://github.com/JohnnyMorganz/StyLua",
      description = "An opinionated Lua code formatter",
    },
    options = {
      command = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "stylua.toml", ".stylua.toml", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local stylua_cmd = find_stylua(root_dir)
        if not stylua_cmd then
          return nil
        end

        -- If we found "devbox", use bash wrapper
        if stylua_cmd == "devbox" then
          return "bash"
        end

        return stylua_cmd
      end,
      args = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "stylua.toml", ".stylua.toml", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local stylua_cmd = find_stylua(root_dir)

        -- If using devbox, wrap the command
        if stylua_cmd == "devbox" then
          return {
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && stylua --stdin-filepath "$0" -', root_dir),
            "$FILENAME",
          }
        end

        -- Standard stylua args
        return { "--stdin-filepath", "$FILENAME", "-" }
      end,
      cwd = function(_, ctx)
        -- Run in project root so stylua can find stylua.toml
        local root_dir = vim.fs.root(ctx.buf, { "stylua.toml", ".stylua.toml", ".git" })
        return root_dir or vim.fn.getcwd()
      end,
    },
  }

  return {
    formatters_by_ft = {
      lua = { "stylua" },
    },
    formatters = {
      stylua = stylua_formatter,
    },
  }
end
