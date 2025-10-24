-- Lua Language Server configuration
-- https://luals.github.io/wiki/settings/
--
-- Note: Additional diagnostics globals are configured in nvim/.luarc.json
-- for cross-editor compatibility (VS Code, other LSP clients, etc.)

return function(capabilities)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function(args)
      local root_dir = vim.fs.root(args.buf, {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        ".git",
      })
      if not root_dir then
        return
      end

      -- Build the command based on what's available
      -- With direnv, devbox environment is already loaded, so tools are in PATH
      local cmd
      -- Check Mason installation first (most common for Neovim config)
      local mason_lua_ls = vim.fn.stdpath "data" .. "/mason/bin/lua-language-server"
      if vim.fn.executable(mason_lua_ls) == 1 then
        cmd = { mason_lua_ls }
      elseif vim.fn.executable "lua-language-server" == 1 then
        -- Use from PATH (includes devbox tools via direnv, or system installation)
        cmd = { "lua-language-server" }
      else
        -- No lua-language-server found - skip starting LSP
        return
      end

      vim.lsp.start {
        name = "lua_ls",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              -- Tells lua_ls where to find all the Lua files that you have loaded
              -- for your neovim configuration.
              library = {
                "${3rd}/luv/library",
                unpack(vim.api.nvim_get_runtime_file("", true)),
              },
              -- If lua_ls is really slow on your computer, you can try this instead:
              -- library = { vim.env.VIMRUNTIME },
            },
            completion = {
              callSnippet = "Replace",
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { "missing-fields" } },
          },
        },
      }
    end,
  })
end
