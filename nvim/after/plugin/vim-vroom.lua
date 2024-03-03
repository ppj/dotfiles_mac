vim.g.vroom_map_keys=0
vim.g.vroom_use_vimux=1
vim.g.vroom_ignore_color_flag=1
vim.keymap.set("n", "<leader>tf", vim.cmd.VroomRunTestFile)
vim.keymap.set("n", "<leader>tt", vim.cmd.VroomRunNearestTest)
vim.keymap.set("n", "<leader>tl", vim.cmd.VroomRunLastTest)
