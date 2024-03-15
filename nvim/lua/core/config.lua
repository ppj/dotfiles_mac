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

-- TODO: Hide some quickfix and git buffers when cycling through buffers
-- WARN: The below from my vimrc prevents the git index from reloading after
-- causing a commit to not reflect in there
--[[
vim.cmd [[
  augroup HideBuffer
  autocmd!
  autocmd FileType qf setlocal nobuflisted
  autocmd FileType gitcommit setlocal nobuflisted
  autocmd BufReadPost *.git/index set nobuflisted
  autocmd BufReadPost *.g/COMMIT_EDITMSG set nobuflisted
  augroup END
]]

-- spell-check on for certain filetypes
vim.cmd "autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_au"
vim.cmd "autocmd FileType gitcommit setlocal spell spelllang=en_us"

vim.cmd "autocmd VimResized * :wincmd =" -- Auto-resize splits if window is resized

-- Use Ag for grep
vim.opt.grepprg = "ag --nogroup --smart-case --follow --vimgrep --hidden --ignore '**.git/*'"
vim.opt.grepformat = "%f:%l:%c:%m"
-- Auto-open quickfix list post grep
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  desc = "Auto-open QF list post grep",
  group = vim.api.nvim_create_augroup("quickfix", { clear = true }),
  pattern = "[^l]*",
  callback = function()
    vim.cmd.cwindow()
  end,
})

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

vim.opt.signcolumn = "yes:2" -- Keep signcolumn on with 2-char width
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!

vim.opt.splitright = true -- Better buffer splitting
vim.opt.splitbelow = true -- Better buffer splitting
vim.opt.scrolloff = 2 -- Minimum number of screen lines to keep above and below the cursor.
