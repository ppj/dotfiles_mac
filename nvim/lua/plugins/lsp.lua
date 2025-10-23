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

    -- Helper function to check if a package is available in devbox
    local function is_package_in_devbox(devbox_root, package_name)
      local devbox_json = devbox_root .. "/devbox.json"
      if vim.fn.filereadable(devbox_json) ~= 1 then
        return false
      end

      -- Read and parse devbox.json
      local ok, content = pcall(vim.fn.readfile, devbox_json)
      if not ok then
        return false
      end

      local json_str = table.concat(content, "\n")
      local ok_decode, data = pcall(vim.json.decode, json_str)
      if not ok_decode then
        return false
      end

      -- Check if package is in the packages list
      if data.packages then
        for _, pkg in ipairs(data.packages) do
          -- Package can be "name" or "name@version"
          local pkg_name = pkg:match "^([^@]+)"
          if pkg_name == package_name then
            return true
          end
        end
      end

      return false
    end

    -- Helper function to find the command to execute (Mason, system PATH, etc.)
    local function find_command(package_name, original_cmd, root_dir)
      -- If original_cmd is specified, use it
      if original_cmd and type(original_cmd) == "table" then
        return original_cmd
      end

      -- Check if we're in a devbox project (even if package isn't in devbox.json)
      local has_devbox = root_dir and vim.fn.filereadable(root_dir .. "/devbox.json") == 1

      -- Check Mason's bin directory
      local mason_bin = vim.fn.stdpath "data" .. "/mason/bin/" .. package_name
      if vim.fn.executable(mason_bin) == 1 then
        -- If this is a devbox project, wrap Mason's LSP to run with devbox environment
        -- This gives the LSP access to the project's dependencies and environment
        if has_devbox then
          -- Use bash to load devbox environment and run the LSP
          return {
            "bash",
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && exec "%s"', root_dir, mason_bin),
          }
        else
          return { mason_bin }
        end
      end

      -- Check if it's in system PATH
      if vim.fn.executable(package_name) == 1 then
        if has_devbox then
          return {
            "bash",
            "-c",
            string.format('cd "%s" && eval "$(devbox shellenv)" && exec "%s"', root_dir, package_name),
          }
        else
          return { package_name }
        end
      end

      -- Last resort: just use the package name and hope it's in PATH
      return { package_name }
    end

    -- Wrapper function to setup LSP with devbox detection using native vim.lsp.config
    local function setup_lsp_with_devbox(server_name, server_config, capabilities)
      local config = vim.tbl_deep_extend("force", {}, server_config)
      config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})

      -- Convert root_markers to root_dir function if specified
      if config.root_markers then
        local markers = config.root_markers
        config.root_dir = function(fname)
          return vim.fs.root(fname, markers)
        end
        config.root_markers = nil -- Remove custom field before passing to vim.lsp.config
      end

      -- Check if server has devbox_package specified
      local devbox_package = config.devbox_package
      config.devbox_package = nil -- Remove from config before passing to vim.lsp.config

      if devbox_package then
        -- Store original cmd if exists
        local original_cmd = config.cmd

        -- Create a custom on_new_config callback to adjust cmd based on devbox detection
        local original_on_new_config = config.on_new_config

        config.on_new_config = function(new_config, root_dir)
          -- First call original callback if it exists
          if original_on_new_config then
            original_on_new_config(new_config, root_dir)
          end

          -- Check if this is a devbox project AND the package is available in devbox
          if root_dir and is_package_in_devbox(root_dir, devbox_package) then
            -- Use devbox run to execute the LSP (cd to root_dir first for devbox < 0.16)
            -- Special handling for solargraph which needs "stdio" argument
            local run_cmd = devbox_package
            if devbox_package == "solargraph" then
              run_cmd = devbox_package .. " stdio"
            end
            local cmd = { "bash", "-c", string.format('cd "%s" && devbox run %s', root_dir, run_cmd) }
            -- Append any additional args from original cmd (but not for solargraph since we handle it above)
            if original_cmd and type(original_cmd) == "table" and devbox_package ~= "solargraph" then
              for i = 2, #original_cmd do
                table.insert(cmd, original_cmd[i])
              end
            end
            new_config.cmd = cmd
            require("fidget").notify(string.format("%s: devbox run", server_name), vim.log.levels.INFO)
          else
            -- Not a devbox project OR package not in devbox - look for Mason or system installation
            new_config.cmd = find_command(devbox_package, original_cmd, root_dir)
            local source = new_config.cmd[1]:match("mason") and "Mason" or "system"
            require("fidget").notify(string.format("%s: %s", server_name, source), vim.log.levels.INFO)
          end
        end

        -- Set a temporary cmd that will be replaced by on_new_config when a buffer is opened
        -- Without this, vim.lsp.config will reject the configuration
        -- Use a function that returns nil to defer cmd resolution to on_new_config
        if not config.cmd then
          config.cmd = function(dispatchers, ctx)
            -- This function allows the config to be accepted but defers actual command setup
            return nil
          end
        end
      end

      -- Set the config using vim.lsp.config
      vim.lsp.config(server_name, config)
    end

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

    -- Enable the following language servers
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - devbox_package (string): Name of the devbox package (enables auto-detection for devbox projects)
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - root_markers (table): List of files/dirs to identify project root (e.g., {"Gemfile", ".git"})
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    --
    -- Note: When devbox_package is specified:
    --   - Projects WITH the package in devbox.json: Uses `devbox run <package>`
    --   - Projects with devbox.json but WITHOUT the package: Wraps Mason/system LSP with `devbox shellenv`
    --   - Projects without devbox.json: Uses Mason or system PATH directly
    local servers = {
      -- Example configurations:
      -- clangd = { devbox_package = "clang-tools" },
      -- gopls = { devbox_package = "gopls" },
      -- pyright = { devbox_package = "pyright" },
      -- rust_analyzer = { devbox_package = "rust-analyzer" },
      -- ... etc. Add any LSP server you need with its corresponding devbox package name
      --
      -- Some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      --
      -- But for many setups, the LSP (`tsserver`) will work just fine
      -- ts_ls, ruby_lsp, and pyright are configured separately below (can't use cmd as function with vim.lsp.config)

      lua_ls = {
        devbox_package = "lua-language-server",
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
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
      },
    }

    -- Mason is still available for manual tool management
    --  To manually install tools, you can run:
    --    :Mason
    --
    --  You can press `g?` for help in this menu
    require("mason").setup()

    -- Note: Mason automatic installation is disabled.
    -- For devbox projects WITH LSP in devbox.json: Uses `devbox run <package>`
    -- For devbox projects WITHOUT LSP in devbox.json: Uses Mason/system LSP wrapped with `devbox shellenv`
    -- For non-devbox projects: Uses Mason/system LSP directly (install via :Mason, system package manager, or PATH)
    --
    -- Optional: Uncomment below to have Mason auto-install specific tools for non-devbox projects
    -- require("mason-tool-installer").setup {
    --   ensure_installed = {
    --     "stylua",      -- Lua formatter
    --     "standardrb",  -- Ruby linter/formatter
    --     "prettier",    -- JavaScript formatter
    --     "eslint_d",    -- JavaScript linter
    --   }
    -- }

    -- Setup LSPs with devbox auto-detection
    for server_name, server_config in pairs(servers) do
      setup_lsp_with_devbox(server_name, server_config, capabilities)
    end

    -- Enable all configured LSPs
    -- They will auto-attach to buffers based on their configured filetypes
    for server_name, _ in pairs(servers) do
      vim.lsp.enable(server_name)
    end

    -- Setup ts_ls separately (needs dynamic cmd based on project root)
    -- TypeScript projects typically have typescript-language-server in node_modules
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

    -- Setup ruby_lsp separately (needs dynamic cmd based on project root)
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

    -- Setup pyright separately (needs dynamic cmd based on project root)
    -- Pyright is the open-source equivalent to VS Code's Pylance
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
