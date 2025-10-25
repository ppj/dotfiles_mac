-- Ruby Language Server configuration
-- Prefers ruby-lsp from Gemfile, falls back to Mason/system

return function(capabilities)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "ruby",
    callback = function(args)
      local root_dir = vim.fs.root(args.buf, { "Gemfile", ".git" })
      if not root_dir then
        return
      end

      -- Build the command based on what's available
      -- With direnv, devbox environment is already loaded, so tools are in PATH
      -- Note: ruby-lsp automatically detects and works with bundler projects,
      -- so we don't need to wrap it in "bundle exec"
      local cmd
      if vim.fn.executable "ruby-lsp" == 1 then
        -- Use from PATH (includes devbox tools via direnv, or system installation)
        cmd = { "ruby-lsp" }
      else
        -- Check Mason installation as fallback
        local mason_ruby_lsp = vim.fn.stdpath "data" .. "/mason/bin/ruby-lsp"
        if vim.fn.executable(mason_ruby_lsp) == 1 then
          cmd = { mason_ruby_lsp }
        else
          -- No ruby-lsp found - skip starting LSP
          return
        end
      end

      vim.lsp.start {
        name = "ruby_lsp",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
      }
    end,
  })
end
