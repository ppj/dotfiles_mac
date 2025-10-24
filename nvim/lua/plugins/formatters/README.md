# Formatters Configuration

This directory contains modular formatter configurations for use with [conform.nvim](https://github.com/stevearc/conform.nvim).

## Architecture

Each language has its own file that exports a function returning formatter configuration:

```lua
return function()
  return {
    formatters_by_ft = {
      -- Map file types to formatters
      typescript = { "prettier" },
    },
    formatters = {
      -- Custom formatter definitions with devbox support
      prettier = { ... },
    },
  }
end
```

## Priority Order

All formatters follow the same priority order for finding executables:

1. **Project-specific installation**
   - JavaScript/TypeScript: `node_modules/.bin/`
   - Ruby: `bundle exec` (if Gemfile exists)
   - Python: `.venv/bin/`

2. **Devbox environment** (if `devbox.json` exists)
   - Runs formatter within `devbox shellenv`

3. **Mason installation**
   - Checks `~/.local/share/nvim/mason/bin/`

4. **System PATH**
   - Falls back to system-installed formatter

5. **Skip gracefully** if not found

## Config File Detection

Formatters automatically respect project-specific configuration files by running in the project root directory:

- **Prettier**: `.prettierrc`, `.prettierrc.js`, `prettier.config.js`, `package.json`
- **StandardRB**: `.standard.yml`
- **Black**: `pyproject.toml` `[tool.black]`
- **isort**: `pyproject.toml` `[tool.isort]`
- **Stylua**: `stylua.toml`, `.stylua.toml`

## Existing Formatters

### TypeScript/JavaScript (`typescript.lua`)
- **Formatter**: prettier
- **File types**: typescript, typescriptreact, javascript, javascriptreact, json, jsonc, css, scss, html, yaml, markdown
- **Project config**: `.prettierrc`, `.prettierrc.js`, `prettier.config.js`

### Ruby (`ruby.lua`)
- **Formatter**: standardrb
- **File types**: ruby
- **Project config**: `.standard.yml`

### Python (`python.lua`)
- **Formatters**: isort (imports), black (code)
- **File types**: python
- **Project config**: `pyproject.toml` with `[tool.black]` and `[tool.isort]`

### Lua (`lua.lua`)
- **Formatter**: stylua
- **File types**: lua
- **Project config**: `stylua.toml`, `.stylua.toml`

## Adding a New Formatter

### Step 1: Create a new file

Create `nvim/lua/plugins/formatters/<language>.lua`:

```lua
-- <Language> formatter configuration
-- Supports <formatter_name> with automatic config detection

return function()
  -- Helper function to find executable
  local function find_formatter(root_dir)
    -- Check project-specific installation
    local local_formatter = root_dir .. "/path/to/formatter"
    if vim.fn.executable(local_formatter) == 1 then
      return local_formatter
    end

    -- Check devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      return "devbox"
    end

    -- Check Mason
    local mason_formatter = vim.fn.stdpath("data") .. "/mason/bin/formatter"
    if vim.fn.executable(mason_formatter) == 1 then
      return mason_formatter
    end

    -- Check system
    if vim.fn.executable("formatter") == 1 then
      return "formatter"
    end

    return nil
  end

  -- Custom formatter definition
  local formatter_config = {
    meta = {
      url = "https://github.com/...",
      description = "...",
    },
    options = {
      command = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "config_file", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local cmd = find_formatter(root_dir)
        if not cmd then
          return nil
        end

        if cmd == "devbox" then
          return "bash"
        end

        return cmd
      end,
      args = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "config_file", ".git" })
        if not root_dir then
          root_dir = vim.fn.getcwd()
        end

        local cmd = find_formatter(root_dir)

        if cmd == "devbox" then
          return {
            "-c",
            string.format(
              'cd "%s" && eval "$(devbox shellenv)" && formatter <args>',
              root_dir
            ),
          }
        end

        return { "<standard_args>" }
      end,
      cwd = function(_, ctx)
        local root_dir = vim.fs.root(ctx.buf, { "config_file", ".git" })
        return root_dir or vim.fn.getcwd()
      end,
    },
  }

  return {
    formatters_by_ft = {
      filetype = { "formatter_name" },
    },
    formatters = {
      formatter_name = formatter_config,
    },
  }
end
```

### Step 2: Load in format.lua

Add to `nvim/lua/plugins/format.lua`:

```lua
local language_config = require("formatters.language")()

-- Merge formatters_by_ft
for ft, formatters in pairs(language_config.formatters_by_ft) do
  formatters_by_ft[ft] = formatters
end

-- Merge formatters
for name, config in pairs(language_config.formatters or {}) do
  formatters[name] = config
end
```

### Step 3: Install the formatter

- For devbox projects: Add to `devbox.json` or install via `devbox global add formatter`
- For non-devbox projects: Install via Mason (`:Mason`) or system package manager

## Testing

1. Open a file of the target type
2. Check formatter is found: `:ConformInfo`
3. Format the file: `<leader>fc` or `:w` (auto-format on save)
4. Verify project config is respected by checking formatting matches project rules

## Troubleshooting

- **Formatter not found**: Check the priority order and ensure it's installed
- **Config not respected**: Verify you're in the project root and config file exists
- **Devbox errors**: Ensure `devbox shellenv` works in your shell
- **Format on save not working**: Check `format_on_save` setting in `format.lua`
