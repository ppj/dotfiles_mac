# LSP Configurations

Individual LSP configurations for Neovim, each in its own modular file.

## Files

- **`lua_ls.lua`** - Lua language server (for Neovim config and Lua projects)
- **`ts_ls.lua`** - TypeScript/JavaScript language server
- **`ruby_lsp.lua`** - Ruby language server
- **`pyright.lua`** - Python language server (Pylance equivalent)

## Architecture

Each LSP file exports a function that takes `capabilities` as a parameter and sets up a FileType autocommand. This allows for:

- **Dynamic command resolution** based on project structure
- **Consistent priority order** across all LSPs
- **Modular organization** - easy to add/remove/modify individual LSPs

## Priority Order

All LSPs follow this priority order:

1. **Project-specific installation**
   - TypeScript: `node_modules/.bin/typescript-language-server`
   - Python: `.venv/bin/pyright-langserver`
   - Ruby: `bundle exec ruby-lsp` (from Gemfile)

2. **Devbox shell environment** (if `devbox.json` exists)
   - Wraps LSP with `eval "$(devbox shellenv)"`
   - Provides access to devbox packages

3. **Mason installation**
   - `~/.local/share/nvim/mason/bin/<lsp-name>`
   - Fallback for non-devbox projects

4. **System PATH**
   - Globally installed LSPs

5. **Graceful skip**
   - If no LSP found, silently skips

## Adding a New LSP

To add a new LSP, create a new file in this directory following the pattern:

```lua
-- <Language> Language Server configuration
-- Description and notes

return function(capabilities)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "<filetype>",
    callback = function(args)
      local root_dir = vim.fs.root(args.buf, { "<root_markers>" })
      if not root_dir then
        return
      end

      -- Build cmd based on priority order
      local cmd
      -- 1. Project-specific
      -- 2. Devbox shell environment
      -- 3. Mason
      -- 4. System PATH
      -- 5. Return if not found

      vim.lsp.start({
        name = "<lsp_name>",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        settings = {
          -- LSP-specific settings
        },
      })
    end,
  })
end
```

Then add `require("lsp.<filename>")(capabilities)` to `lua/plugins/lsp.lua`.

## Usage

These files are loaded from `lua/plugins/lsp.lua`:

```lua
require("lsp.lua_ls")(capabilities)
require("lsp.ts_ls")(capabilities)
require("lsp.ruby_lsp")(capabilities)
require("lsp.pyright")(capabilities)
```

## Benefits

- **Modularity**: Each LSP in its own file
- **Maintainability**: Easy to modify individual LSPs without affecting others
- **Clarity**: Clear separation of concerns
- **Scalability**: Simple to add new LSPs
- **Consistency**: All LSPs follow the same pattern
