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
      -- With direnv, devbox environment is already loaded, so tools are in PATH
      local cmd
      -- Check for local node_modules installation first (most common for npm/pnpm/yarn projects)
      local local_tsserver = root_dir .. "/node_modules/.bin/typescript-language-server"
      if vim.fn.executable(local_tsserver) == 1 then
        -- Use project's typescript-language-server directly
        cmd = { local_tsserver, "--stdio" }
      elseif vim.fn.executable "typescript-language-server" == 1 then
        -- Use from PATH (includes devbox tools via direnv, or system installation)
        cmd = { "typescript-language-server", "--stdio" }
      else
        -- Check Mason installation as fallback
        local mason_tsserver = vim.fn.stdpath "data" .. "/mason/bin/typescript-language-server"
        if vim.fn.executable(mason_tsserver) == 1 then
          cmd = { mason_tsserver, "--stdio" }
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
