return {
  { -- Rails
    "tpope/vim-rails",
    config = function()
      vim.keymap.set("n", "<leader>aa", ":A<CR>", { desc = "[A]ssociated file" })
      vim.keymap.set("n", "<leader>av", ":AV<CR>", { desc = "[A]ssociated file in [v]ertical split" })
    end,
  },
}
