-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- empty setup using defaults
require("nvim-tree").setup()

-- mappings
vim.keymap.set('n', '<leader>nn', vim.cmd.NvimTreeToggle)
vim.keymap.set('n', '<leader>nf', vim.cmd.NvimTreeFindFile)
