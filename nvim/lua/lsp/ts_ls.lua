-- TypeScript/JavaScript Language Server configuration
-- Supports TypeScript, TSX, JavaScript, and JSX files

return function(capabilities)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    callback = function(args)
      local root_dir = vim.fs.root(args.buf, { "package.json", "tsconfig.json", "jsconfig.json", ".git" })
      if not root_dir then
        return
      end

      -- Build the command based on what's available
      local cmd
      -- Check for local node_modules installation first (most common for npm/pnpm/yarn projects)
      local local_tsserver = root_dir .. "/node_modules/.bin/typescript-language-server"
      if vim.fn.executable(local_tsserver) == 1 then
        -- Use project's typescript-language-server directly
        cmd = { local_tsserver, "--stdio" }
      elseif vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
        -- Devbox project without local installation: try within devbox shell environment
        -- TypeScript LSP will be available if typescript-language-server is in package.json dev dependencies
        cmd = {
          "bash",
          "-c",
          string.format('cd "%s" && eval "$(devbox shellenv)" && typescript-language-server --stdio', root_dir),
        }
      else
        -- Check Mason installation
        local mason_tsserver = vim.fn.stdpath "data" .. "/mason/bin/typescript-language-server"
        if vim.fn.executable(mason_tsserver) == 1 then
          -- Use Mason's typescript-language-server
          cmd = { mason_tsserver, "--stdio" }
        elseif vim.fn.executable "typescript-language-server" == 1 then
          -- Use system installation if available
          cmd = { "typescript-language-server", "--stdio" }
        else
          -- No typescript-language-server found - skip starting LSP
          return
        end
      end

      vim.lsp.start {
        name = "ts_ls",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
      }
    end,
  })
end
