# Linters Configuration

This directory contains modular linter configurations for use with [nvim-lint](https://github.com/mfussenegger/nvim-lint).

## Architecture

Each language has its own file that exports a function returning linter configuration:

```lua
return function()
  return {
    linters_by_ft = {
      -- Map file types to linters
      typescript = { "eslint" },
    },
    linters = {
      -- Custom linter definitions with devbox support
      eslint = { ... },
    },
  }
end
```

## Priority Order

All linters follow the same priority order for finding executables:

1. **Project-specific installation**
   - JavaScript/TypeScript: `node_modules/.bin/`
   - Ruby: `bundle exec` (if Gemfile exists)
   - Python: `.venv/bin/`

2. **Devbox environment** (if `devbox.json` exists)
   - Runs linter within `devbox shellenv`

3. **Mason installation**
   - Checks `~/.local/share/nvim/mason/bin/`

4. **System PATH**
   - Falls back to system-installed linter

5. **Skip gracefully** if not found

## Config File Detection

Linters automatically respect project-specific configuration files by running in the project root directory:

- **ESLint**: `.eslintrc.js`, `.eslintrc.json`, `eslint.config.js`, `package.json`
- **Rubocop**: `.rubocop.yml`
- **Standard**: `.standard.yml`
- **Pylint**: `pyproject.toml` `[tool.pylint]`, `.pylintrc`

## Relationship with LSPs

Linters provide **code quality and style rules**, while LSPs provide **type checking and syntax errors**:

- **TypeScript/JavaScript**:
  - LSP (`ts_ls`): Type errors, undefined variables, syntax errors
  - Linter (`eslint`): Code style, best practices, React rules, etc.

- **Ruby**:
  - LSP (`ruby_lsp`): Syntax errors, method resolution
  - Linter (`rubocop`): Style guide violations, code smells

- **Python**:
  - LSP (`pyright`): Type errors, import resolution
  - Linter (`pylint`): Code quality, conventions, complexity

This separation avoids duplicate diagnostics while providing comprehensive code analysis.

## Existing Linters

### TypeScript/JavaScript (`typescript.lua`)
- **Linter**: eslint
- **File types**: typescript, typescriptreact, javascript, javascriptreact
- **Project config**: `.eslintrc.js`, `.eslintrc.json`, `eslint.config.js`
- **What it checks**: Code style, best practices, React rules, accessibility

### Ruby (`ruby.lua`)
- **Linter**: rubocop
- **File types**: ruby
- **Project config**: `.rubocop.yml`, `.standard.yml`
- **What it checks**: Ruby style guide, code smells, complexity

### Python (`python.lua`)
- **Linter**: pylint
- **File types**: python
- **Project config**: `pyproject.toml` `[tool.pylint]`, `.pylintrc`
- **What it checks**: Code quality, conventions, potential errors

## Adding a New Linter

### Step 1: Create a new file

Create `nvim/lua/plugins/linters/<language>.lua`:

```lua
-- <Language> linter configuration
-- Supports <linter_name> with automatic config detection

return function()
  -- Helper function to find executable
  local function find_linter(root_dir)
    -- Check project-specific installation
    local local_linter = root_dir .. "/path/to/linter"
    if vim.fn.executable(local_linter) == 1 then
      return local_linter
    end

    -- Check devbox project
    if vim.fn.filereadable(root_dir .. "/devbox.json") == 1 then
      return "devbox"
    end

    -- Check Mason
    local mason_linter = vim.fn.stdpath("data") .. "/mason/bin/linter"
    if vim.fn.executable(mason_linter) == 1 then
      return mason_linter
    end

    -- Check system
    if vim.fn.executable("linter") == 1 then
      return "linter"
    end

    return nil
  end

  -- Create custom linter with devbox support
  local linter = {
    cmd = "linter",
    stdin = true,  -- or false if linter requires file path
    args = {
      "--format",
      "json",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    },
    stream = "stdout",
    ignore_exitcode = true,
    parser = require("lint.linters.linter").parser,
  }

  -- Override cmd function to use our custom resolution
  linter.cmd = function()
    local root_dir = vim.fs.root(0, { "config_file", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local cmd = find_linter(root_dir)
    if not cmd then
      return "linter" -- fallback
    end

    if cmd == "devbox" then
      return "bash"
    end

    return cmd
  end

  -- Override args to support devbox
  local original_args = linter.args
  linter.args = function()
    local root_dir = vim.fs.root(0, { "config_file", ".git" })
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end

    local cmd = find_linter(root_dir)
    local filename = vim.api.nvim_buf_get_name(0)

    if cmd == "devbox" then
      return {
        "-c",
        string.format(
          'cd "%s" && eval "$(devbox shellenv)" && linter <args> "%s"',
          root_dir,
          filename
        ),
      }
    end

    -- Standard args - resolve functions
    local args = {}
    for _, arg in ipairs(original_args) do
      if type(arg) == "function" then
        table.insert(args, arg())
      else
        table.insert(args, arg)
      end
    end
    return args
  end

  return {
    linters_by_ft = {
      filetype = { "linter_name" },
    },
    linters = {
      linter_name = linter,
    },
  }
end
```

### Step 2: Load in lint.lua

Add to `nvim/lua/plugins/lint.lua`:

```lua
local language_config = require("linters.language")()

-- Merge linters_by_ft
for ft, linters in pairs(language_config.linters_by_ft) do
  linters_by_ft[ft] = linters
end

-- Merge linters
for name, config in pairs(language_config.linters or {}) do
  lint.linters[name] = config
end
```

### Step 3: Install the linter

- For devbox projects: Add to `devbox.json` or install via `devbox global add linter`
- For non-devbox projects: Install via Mason (`:Mason`) or system package manager

## Linting Triggers

Linting runs automatically on:
- `BufEnter` - When you open a file
- `BufWritePost` - After saving
- `InsertLeave` - When leaving insert mode

Configure in `nvim/lua/plugins/lint.lua`.

## Testing

1. Open a file with intentional errors
2. Verify diagnostics appear in the buffer
3. Check project config is respected: `:lua print(vim.inspect(require("lint").linters_by_ft))`
4. Manual trigger: `:lua require("lint").try_lint()`

## Troubleshooting

- **No diagnostics**: Check linter is installed and in PATH
- **Config not respected**: Verify you're in project root and config file exists
- **Devbox errors**: Ensure `devbox shellenv` works in your shell
- **Too many diagnostics**: May need to disable conflicting LSP diagnostics
- **Linter not running**: Check autocmd triggers in `lint.lua`
