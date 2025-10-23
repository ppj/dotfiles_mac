return { -- LSP Configuration & Plugins
  -- Using Neovim 0.11+ native LSP configuration (vim.lsp.config)
  -- No longer needs nvim-lspconfig or mason-lspconfig plugins
  "williamboman/mason.nvim",
  dependencies = {
    -- Useful status updates for LSP.
    { "j-hui/fidget.nvim", opts = {} }, -- NOTE: `opts = {}` is the same as calling `require("fidget").setup({})`
  },
  config = function()
    -- Brief Aside: **What is LSP?**
    --
    -- LSP is an acronym you've probably heard, but might not understand what it is.
    --
    -- LSP stands for Language Server Protocol. It's a protocol that helps editors
    -- and language tooling communicate in a standardized fashion.
    --
    -- In general, you have a "server" which is some tool built to understand a particular
    -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
    -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
    -- processes that communicate with some "client" - in this case, Neovim!
    --
    -- LSP provides Neovim with features like:
    --  - Go to definition
    --  - Find references
    --  - Autocompletion
    --  - Symbol Search
    --  - and more!
    --
    -- Thus, Language Servers are external tools that must be installed separately from
    -- Neovim. This is where `mason` and related plugins come into play.
    --
    -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
    -- and elegantly composed help section, `:help lsp-vs-treesitter`

    --  This function gets run when an LSP attaches to a particular buffer.
    --    That is to say, every time a new file is opened that is associated with
    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    --    function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-T>.
        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

        -- Find references for the word under your cursor.
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

        -- Fuzzy find all the symbols in your current workspace
        --  Similar to document symbols, except searches over your whole project.
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

        -- Rename the variable under your cursor
        --  Most Language Servers support renaming across files, etc.
        -- map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

        -- Opens a popup that displays documentation about the word under your cursor
        --  See `:help K` for why this keymap
        map("K", vim.lsp.buf.hover, "Hover Documentation")

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP Specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    -- All LSPs are configured via FileType autocommands below
    -- This approach allows dynamic cmd building based on project structure (devbox, node_modules, venv, etc.)
    --
    -- Currently configured LSPs:
    --  - lua_ls: Lua language server (for Neovim config and Lua projects)
    --  - ts_ls: TypeScript/JavaScript language server
    --  - ruby_lsp: Ruby language server
    --  - pyright: Python language server (Pylance equivalent)
    --
    -- To add more LSPs, follow the same FileType autocommand pattern with priority order:
    --  1. Project-specific installation (node_modules, .venv, Gemfile)
    --  2. Devbox shell environment (if devbox.json exists)
    --  3. Mason installation (~/.local/share/nvim/mason/bin/)
    --  4. System PATH
    --  5. Graceful skip if not found
    --
    -- Note: This approach provides maximum flexibility:
    --  - Devbox projects: Uses project's devbox environment
    --  - Non-devbox projects: Falls back to Mason or system installation
    --  - Per-project isolation: Each project can use its own LSP version
    local servers = {
      -- Empty table - all LSPs configured via FileType autocommands below
    }

    -- Mason is available for manual tool management
    --  To manually install tools, run:
    --    :Mason
    --  You can press `g?` for help in the Mason menu
    --
    --  Mason provides LSPs as fallback for non-devbox projects.
    --  Useful LSPs to install via Mason:
    --    - lua-language-server (for Neovim config)
    --    - typescript-language-server (for non-devbox TS projects)
    --    - ruby-lsp (for non-Gemfile Ruby scripts)
    --    - pyright (for non-venv Python projects)
    require("mason").setup()

    -- Optional: Uncomment below to have Mason auto-install specific tools
    -- require("mason-tool-installer").setup {
    --   ensure_installed = {
    --     "lua-language-server",
    --     "stylua",      -- Lua formatter
    --     "standardrb",  -- Ruby linter/formatter
    --     "prettier",    -- JavaScript formatter
    --     "eslint_d",    -- JavaScript linter
    --   }
    -- }

    --------------------------------------------------------------------------------
    -- Lua LSP (lua_ls)
    --------------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "lua",
      callback = function(args)
        local root_dir = vim.fs.root(args.buf, { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" })
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

    --------------------------------------------------------------------------------
    -- TypeScript/JavaScript LSP (ts_ls)
    --------------------------------------------------------------------------------
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
          local mason_tsserver = vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server"
          if vim.fn.executable(mason_tsserver) == 1 then
            -- Use Mason's typescript-language-server
            cmd = { mason_tsserver, "--stdio" }
          elseif vim.fn.executable("typescript-language-server") == 1 then
            -- Use system installation if available
            cmd = { "typescript-language-server", "--stdio" }
          else
            -- No typescript-language-server found - skip starting LSP
            return
          end
        end

        vim.lsp.start({
          name = "ts_ls",
          cmd = cmd,
          root_dir = root_dir,
          capabilities = capabilities,
        })
      end,
    })

    --------------------------------------------------------------------------------
    -- Ruby LSP (ruby_lsp)
    --------------------------------------------------------------------------------
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
            cmd = { "bash", "-c", string.format('cd "%s" && eval "$(devbox shellenv)" && bundle exec ruby-lsp', root_dir) }
          else
            -- Not a devbox project: use bundle exec directly
            cmd = { "bundle", "exec", "ruby-lsp" }
          end
        else
          -- No Gemfile - check for Mason or system installation
          local mason_ruby_lsp = vim.fn.stdpath("data") .. "/mason/bin/ruby-lsp"
          if vim.fn.executable(mason_ruby_lsp) == 1 then
            -- Use Mason's ruby-lsp
            cmd = { mason_ruby_lsp }
          elseif vim.fn.executable("ruby-lsp") == 1 then
            -- Use system installation if available
            cmd = { "ruby-lsp" }
          else
            -- No ruby-lsp found - skip starting LSP
            return
          end
        end

        vim.lsp.start({
          name = "ruby_lsp",
          cmd = cmd,
          root_dir = root_dir,
          capabilities = capabilities,
        })
      end,
    })

    --------------------------------------------------------------------------------
    -- Python LSP (pyright)
    -- Open-source equivalent to VS Code's Pylance
    --------------------------------------------------------------------------------
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
  end,
}
