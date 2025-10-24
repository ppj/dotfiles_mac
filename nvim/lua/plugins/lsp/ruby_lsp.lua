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

      -- Build the command based on whether this is a devbox project
      local cmd
      -- Check if ruby-lsp is in Gemfile (most common for Ruby projects)
      local has_gemfile = vim.fn.filereadable(root_dir .. "/Gemfile") == 1
      if has_gemfile then
        if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
          -- Devbox project: run bundle exec within devbox shell environment
          cmd = {
            "bash",
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && bundle exec ruby-lsp', root_dir),
          }
        else
          -- Not a devbox project: use bundle exec directly
          cmd = { "bundle", "exec", "ruby-lsp" }
        end
      else
        -- No Gemfile - check for Mason or system installation
        local mason_ruby_lsp = vim.fn.stdpath "data" .. "/mason/bin/ruby-lsp"
        if vim.fn.executable(mason_ruby_lsp) == 1 then
          -- Use Mason's ruby-lsp
          cmd = { mason_ruby_lsp }
        elseif vim.fn.executable "ruby-lsp" == 1 then
          -- Use system installation if available
          cmd = { "ruby-lsp" }
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
