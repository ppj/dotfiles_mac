
vim.keymap.set("n", "<leader>w", vim.cmd.w)
vim.keymap.set("n", "<leader>q", vim.cmd.q)
vim.keymap.set("n", "<leader>ss", ":source %<CR>")


vim.keymap.set("n", "<leader>l", vim.cmd.bn)
vim.keymap.set("n", "<leader>h", vim.cmd.bp)
vim.keymap.set("n", "<leader>d", vim.cmd.Bd)
-- vim.keymap.set("n", "<leader>b", vim.cmd.ls<cr>:b<space>
vim.keymap.set("n", "<leader>w", vim.cmd.w)
vim.keymap.set("n", "<leader>q", vim.cmd.q)
vim.keymap.set("n", "<leader>e", vim.cmd.e) -- reload file

-- Change window-splits easily
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-b>", "<C-w>p")

-- command history mode (default)
vim.keymap.set("n", ":", "q:i")
-- simple command prompt
vim.keymap.set("n", "<leader>:", ":")

-- move line(s) up/down with Alt+k/j (http://vim.wikia.com/wiki/Moving_lines_up_or_down)
vim.keymap.set("v", "∆", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "˚", ":m '<-2<CR>gv=gv")

-- From https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/remap.lua
vim.keymap.set("n", "J", "mzJ`z")
-- keep cursor in the middle of the window when scrolling or searching
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- keep visually copied string in buffer after pasting visually selected string replaced by <leader>p
vim.keymap.set("x", "<leader>p", [["_dP]]) 
-- copy to system clipboard by pre-using <leader> to yank
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
-- disable Ex mode
vim.keymap.set("n", "Q", "<nop>")
-- quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- find & replace word under cursor
 vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])



