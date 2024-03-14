-------------------------------------------------------------------------------
-- From my old vim config
-------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>w", vim.cmd.w, { desc = "Save file" })
vim.keymap.set("n", "<leader>q", vim.cmd.q, { desc = "Close window" })
-- vim.keymap.set("n", "<leader>ss", ":source %<CR>")

-- copy full file path to clipboard
vim.keymap.set("n", "<leader>fp", function()
  vim.fn.setreg("+", vim.api.nvim_buf_get_name(0))
end, { desc = "Copy [p]ath" })

vim.keymap.set("n", "<leader>l", vim.cmd.bn, { desc = "Next buffer" })
vim.keymap.set("n", "<leader>h", vim.cmd.bp, { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>d", vim.cmd.Bd, { desc = "Close buffer (not window)" })
vim.keymap.set("n", "<leader>e", vim.cmd.e, { desc = "Reload file" }) -- reload file

-- Move to split window easily
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-b>", "<C-w>p")

vim.keymap.set("n", ":", "q:i") -- command history mode (default)
vim.keymap.set("n", "<leader>:", ":", { desc = "Simple command prompt" })

-- move line(s) up/down with Shift+k/j (http://vim.wikia.com/wiki/Moving_lines_up_or_down)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Plugin management
vim.keymap.set("n", "<C-p>", ":Lazy<CR>", { desc = "O[p]en" })

-------------------------------------------------------------------------------
-- From https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua
-------------------------------------------------------------------------------
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- clear highlight on pressing <Esc> in normal mode

-- Diagnostic keymaps (NOT SURE WHAT THESE ARE. ENABLE IF USEFUL LATER)
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set("n", "<left>", "<cmd>echo "Use h to move!!"<CR>")
-- vim.keymap.set("n", "<right>", "<cmd>echo "Use l to move!!"<CR>")
-- vim.keymap.set("n", "<up>", "<cmd>echo "Use k to move!!"<CR>")
-- vim.keymap.set("n", "<down>", "<cmd>echo "Use j to move!!"<CR>")

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank { on_visual = false, timeout = 250 }
  end,
})

-- Search for visual selection
vim.keymap.set("v", "*", 'y/<C-R>"<CR>', { remap = true })
vim.keymap.set("v", "#", 'y?<C-R>"<CR>', { remap = true })

-- move cursor up/down by screen lines ONLY WHEN used without a count
vim.keymap.set("n", "j", 'v:count == 0 ? "gj" : "j"', { expr = true, silent = true })
vim.keymap.set("n", "k", 'v:count == 0 ? "gk" : "k"', { expr = true, silent = true })

-- noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

-------------------------------------------------------------------------------
-- From https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/remap.lua
-------------------------------------------------------------------------------
-- keep cursor in the current place when ...
vim.keymap.set("n", "J", "mzJ`z") -- ... joining next line
vim.keymap.set("n", "*", "mz*`z") -- ... starting to search down
vim.keymap.set("n", "#", "mz#`z") -- ... starting to search up
-- keep cursor in the middle of the window when ...
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- ... scrolling down
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- ... scrolling up
vim.keymap.set("n", "n", "nzzzv") -------- ... searching down
vim.keymap.set("n", "N", "Nzzzv") -------- ... searching up

-- keep visually copied string in buffer after pasting visually selected string replaced by <leader>p
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "" })
-- copy to system clipboard by pre-using <leader> to yank
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
-- disable Ex mode
vim.keymap.set("n", "Q", "<nop>")
-- quickfix navigation
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- find & replace word under cursor
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
