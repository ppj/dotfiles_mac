-- Python Language Server configuration
-- Open-source equivalent to VS Code's Pylance
-- Prefers .venv/bin installation (Poetry), falls back to devbox/Mason/system

return function(capabilities)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
      local root_dir = vim.fs.root(args.buf, { "pyproject.toml", "setup.py", ".git" })
      if not root_dir then
        return
      end

      -- Build the command based on whether this is a devbox project
      local cmd
      -- Check for .venv/bin/pyright-langserver first (most common for Poetry projects)
      local venv_pyright = root_dir .. "/.venv/bin/pyright-langserver"
      if vim.fn.executable(venv_pyright) == 1 then
        -- Use .venv's pyright directly
        cmd = { venv_pyright, "--stdio" }
      elseif vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
        -- Devbox project without venv: try within devbox shell environment
        cmd = {
          "bash",
          "-c",
          string.format('cd "%s" && eval "$(devbox shellenv)" && pyright-langserver --stdio', root_dir),
        }
      else
        -- Not a devbox project and no venv: check Mason or system
        local mason_pyright = vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver"
        if vim.fn.executable(mason_pyright) == 1 then
          -- Use Mason's pyright
          cmd = { mason_pyright, "--stdio" }
        elseif vim.fn.executable("pyright-langserver") == 1 then
          -- Use system installation if available
          cmd = { "pyright-langserver", "--stdio" }
        else
          -- No pyright-langserver found - skip starting LSP
          return
        end
      end

      vim.lsp.start({
        name = "pyright",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })
    end,
  })
end
