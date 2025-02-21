-------------------------------------------------------------------------------
-- Better UX
-------------------------------------------------------------------------------
-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Whitespace etc.
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "•", extends = "❯", nbsp = "␣", precedes = "❮", eol = "¬" }

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true -- highlight hits incrementally while typing the search term
vim.opt.hidden = true -- better tab management

vim.opt.autoread = true -- auto load file changes occured outside vim
vim.opt.undofile = true -- Save undo history
-- vim.opt.clipboard = "unnamedplus" -- Always use the system clipboard

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Hide some quickfix and git buffers when cycling through buffers
vim.api.nvim_create_augroup("HideBuffer", { clear = true })
vim.api.nvim_create_autocmd({ "FileType", "BufReadPre", "BufReadPost" }, {
  group = "HideBuffer",
  pattern = { "qf", "*.git/index", "*.g/COMMIT_EDITMSG" },
  callback = function()
    vim.opt.buflisted = false
    vim.opt_local.buflisted = false
  end,
})

-- spell-check on for certain filetypes
vim.api.nvim_create_augroup("SpellCheck", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "SpellCheck",
  pattern = "gitcommit",
  command = "setlocal spell spelllang=en_au",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "SpellCheck",
  pattern = "*.md",
  command = "setlocal spell spelllang=en_us",
})

vim.cmd "autocmd VimResized * :wincmd =" -- Auto-resize splits if window is resized

-- Use Ag for grep
vim.opt.grepprg = "ag --nogroup --smart-case --follow --vimgrep --hidden --skip-vcs-ignores --ignore={'**.git/*','**node_modules/*','**.devbox/*'}"
vim.opt.grepformat = "%f:%l:%c:%m"

-------------------------------------------------------------------------------
-- Better UI
-------------------------------------------------------------------------------
vim.opt.termguicolors = true -- enable 24-bit colour
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "121"
vim.opt.showmode = false -- mode is already shown in the status line
vim.opt.breakindent = true -- word-wrapped line-breaks respect indentation
vim.opt.mouse = "a" -- mouse to resize splits etc.

-- Disable relative numbering in insert mode or when not the active buffer (from my vimrc)
vim.cmd [[
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
]]

vim.opt.signcolumn = "yes:2" -- Keep signcolumn on with 2-char width
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!

vim.opt.splitright = true -- Better buffer splitting
vim.opt.splitbelow = true -- Better buffer splitting
vim.opt.scrolloff = 2 -- Minimum number of screen lines to keep above and below the cursor.
