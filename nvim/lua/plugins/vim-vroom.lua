return {
  "skalnik/vim-vroom", -- Ruby test runner that works well with tmux
  config = function()
    vim.g.vroom_map_keys = 0
    vim.g.vroom_use_vimux = 1
    vim.g.vroom_ignore_color_flag = 1
    vim.keymap.del("n", "<leader>r")
    vim.keymap.set("n", "<leader>tf", vim.cmd.VroomRunTestFile, { desc = "Run [T]est [F]ile" })
    vim.keymap.set("n", "<leader>tt", vim.cmd.VroomRunNearestTest, { desc = "Run [T]est Current[t]" })
    vim.keymap.set("n", "<leader>tl", vim.cmd.VroomRunLastTest, { desc = "Run [T]est [L]ast" })
  end,
}
