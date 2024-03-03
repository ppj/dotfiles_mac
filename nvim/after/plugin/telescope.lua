local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>oo", builtin.git_files, {})
vim.keymap.set("n", "<leader>ob", builtin.buffers, {})
vim.keymap.set("n", "<leader>oa", builtin.find_files, {})
