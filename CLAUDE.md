# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Working Guidelines

**Important**: When reading code or performing code analysis tasks, prefer using Gemini CLI wherever possible instead of reading files directly. Gemini CLI is optimized for code understanding and analysis workflows.

Example usage:
```bash
# Analyze code with a specific prompt
gemini -p "Explain what this function does and identify any potential issues" path/to/file.js

# Analyze multiple files
gemini -p "Compare these implementations" file1.rb file2.rb

# Analyze code with context from directory
gemini -p "Review this module for best practices" src/module/
```

## Repository Overview

This is a personal macOS dotfiles repository for managing shell, editor, and terminal configurations. The repository uses symlinks to deploy configuration files from this central location to their expected system locations.

## Installation & Setup Commands

### Initial Installation (in order)
```bash
# 1. Clone repository
git clone git@github.com:ppj/dotfiles_mac.git $HOME/dotfiles_mac

# 2. Install homebrew and iTerm2
$HOME/dotfiles_mac/scripts/brew_and_iterm2.sh

# 3. Install remaining tools (zsh, tmux, neovim, fzf, ag, etc.)
$HOME/dotfiles_mac/scripts/setup.sh

# 4. Create symlinks to config files
$HOME/dotfiles_mac/scripts/symlinks.sh

# 5. Setup Vim with Vundle and plugins
$HOME/dotfiles_mac/scripts/vim_setup.sh
```

### Important: Symlink Behavior
The `symlinks.sh` script **overwrites existing symlinks and files** without confirmation. It creates symlinks for:
- Root config files: `gitconfig`, `vimrc`, `zshrc`, `tmux.conf`, `starship.toml` → `~/.*`
- Deep directory structures: `nvim/` and `ghostty/` → `~/.config/`
- Claude Code settings: `claude/settings.json` → `~/.claude/settings.json`

## Architecture & Configuration

### Shell Configuration (zshrc)
- **Framework**: oh-my-zsh with custom plugins (zsh-syntax-highlighting, zsh-autosuggestions, z, history-substring-search)
- **Prompt**: Starship (configured via `starship.toml`)
- **Editor**: nvim (set as EDITOR, VISUAL, USE_EDITOR)
- **Key bindings**: Vi mode enabled with Ctrl-Z for fg/clear-screen toggle
- **Default editor**: nvim (changed from vim)

#### Important Shell Functions
- `clean_merged_branches`: Safely delete merged git branches with confirmation
- `start_aws_session`: Interactive AWS EC2 instance selector with SSM session
- `nvims`: fzf-based selector for multiple Neovim distributions (LazyVim, Kickstart, AstroNvim)

#### Path Management
- `~/.local/bin` is in PATH (duplicates removed in recent commits)
- asdf shims take precedence over system paths
- Homebrew paths: `/usr/local/sbin`, `/usr/local/opt/openssl@3/bin`

#### Tool Integration
- **direnv**: Hook enabled for per-directory environment variables
- **devbox**: Global shellenv configured
- **fzf**: Integrated with `--zsh` flag
- **granted**: AWS credential management with auto-reassume
- **hub**: Aliased to `git` command

### Vim/Neovim Setup

#### Vim (vimrc)
- **Plugin manager**: Vundle
- **Leader key**: Space
- **Color scheme**: mopkai (custom, in `vim/colors/`)
- **Key plugins**: NERDTree, CtrlP, vim-fugitive, vim-tmux-navigator, vimux, vim-vroom, ALE, vim-surround
- **Grep**: Uses `ag` (The Silver Searcher) with ignore patterns for common dirs
- **Ruby**: Rails support, ruby-refactoring, blockle, vim-ruby
- **JavaScript**: jsx, prettier, typescript support
- **Testing**: vim-vroom with vimux integration

#### Neovim (nvim/)
- **Plugin manager**: Lazy.nvim (auto-installed in `init.lua`)
- **Structure**:
  - `init.lua`: Entry point, bootstraps Lazy.nvim
  - `lua/core/config.lua`: Core settings (whitespace, search, UI)
  - `lua/core/keymaps.lua`: Key mappings
  - `lua/plugins/`: Plugin configurations (modular)
  - `lua/plugins/lsp/`: Language server configurations (Ruby, Lua, Python, TypeScript)
- **Grep**: Uses `ag` with ignore patterns: git, node_modules, .devbox, log, __snapshots__, pnpm-lock.yaml, .next, .turbo

### Tmux Configuration (tmux.conf)
- **Plugin manager**: TPM (Tmux Plugin Manager)
- **Theme**: Dracula with powerline, showing git/time/weather
- **Vi mode**: Enabled for copy mode
- **Vim integration**: Custom `is_vim` detection for seamless pane navigation (C-h/j/k/l)
- **Mouse**: Enabled by default (toggle with prefix+m/M)
- **New windows/splits**: Inherit current pane's working directory

### Git Configuration (gitconfig)
- **Default branch**: main
- **Pull strategy**: No rebase (merge)
- **Push**: Current branch, auto-setup remote, follow tags
- **Fetch**: Prune deleted branches and tags, fetch all remotes
- **Rebase**: Auto-squash, auto-stash, update refs
- **Diff**: Histogram algorithm, color moved lines, mnemonic prefixes
- **Rerere**: Enabled for reuse of conflict resolutions
- **Help**: Autocorrect with prompt
- **Commit**: Verbose mode enabled

### Important Git Aliases (in zshrc)
- `gls`: Combined status and branch list
- `use_latest_master`: Fetch and rebase on origin's main branch
- `delete_merged_branches`: Simple branch cleanup (prefer `clean_merged_branches` function)

## Development Patterns

### Testing in Ruby Projects
Vim-vroom is configured to run tests via vimux in tmux:
- Leader key mappings: `<leader>tf` (file), `<leader>tt` (nearest), `<leader>tl` (last)
- Uses vimux to run tests in tmux pane

### Multiple Neovim Configurations
The setup supports running different Neovim distributions side-by-side:
- Default: `nvim` → `~/.config/nvim`
- LazyVim: `nvim-lazy` → `~/.config/LazyVim`
- Kickstart: `nvim-kick` → `~/.config/kickstart`
- AstroNvim: `nvim-astro` → `~/.config/AstroNvim`
- Interactive selector: `nvims` or Ctrl+A

### Search & File Navigation
**Vim/Neovim:**
- CtrlP for file navigation (uses ag for listing)
- Ack.vim frontend for ag searches
- Visual selection search: `*` (forward), `#` (backward)

**Shell:**
- `ag` is the primary search tool with smart ignore patterns
- `fzf` for fuzzy finding (integrated with shell history and `nvims`)

## Editing Dotfiles
Convenience aliases in zshrc:
- `ev`: Edit vimrc
- `et`: Edit tmux.conf
- `ez`: Edit zshrc

After editing, reload:
- zsh: `source ~/.zshrc`
- tmux: prefix + `r`
- vim: `<leader>ee`

## Environment-Specific Configuration
The repository contains Kafka broker/zookeeper configurations for dev/staging/prod environments. When working with these configs, be careful to distinguish between environments (DEV_BROKERS, STAGING_US_BROKERS, PROD_US_BROKERS, PROD_EU_BROKERS).
