-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- enable 24-bit colour
vim.opt.termguicolors = true

-- Whitespace etc.
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', trail = '•', extends = '❯', nbsp = '_', precedes = '❮', eol = '¬' }

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.autoread = true -- auto load file changes occured outside vim

-- Better editor UI
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.relativenumber = true
-- vim.opt.signcolumn = 'yes:2'
vim.opt.cursorline = true
vim.opt.colorcolumn = '121'
vim.g.indentLine_color_term = 237

-- Makes neovim and host OS clipboard play nicely with each other
-- vim.opt.clipboard = 'unnamedplus'

-- Better buffer splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- mouse mode
vim.opt.mouse = 'a'


