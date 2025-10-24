-- Lua Language Server configuration
-- https://luals.github.io/wiki/settings/

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
      local cmd
      -- Check Mason installation first (most common for Neovim config)
      local mason_lua_ls = vim.fn.stdpath("data") .. "/mason/bin/lua-language-server"
      if vim.fn.executable(mason_lua_ls) == 1 then
        -- Use Mason's lua-language-server
        cmd = { mason_lua_ls }
      elseif vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
        -- Devbox project: try within devbox shell environment
        cmd = {
          "bash",
          "-c",
          string.format('cd "%s" && eval "$(devbox shellenv)" && lua-language-server', root_dir),
        }
      elseif vim.fn.executable("lua-language-server") == 1 then
        -- Use system installation if available
        cmd = { "lua-language-server" }
      else
        -- No lua-language-server found - skip starting LSP
        return
      end

      vim.lsp.start({
        name = "lua_ls",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
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
      })
    end,
  })
end
