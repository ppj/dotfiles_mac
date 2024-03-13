return {
  { -- Rails
    "tpope/vim-rails",
    config = function()
      vim.keymap.set("n", "<leader>aa", ":A<CR>", { desc = "[A]ssociated file" })
      vim.keymap.set("n", "<leader>av", ":AV<CR>", { desc = "[A]ssociated file in [v]ertical split" })
    end,
  },
  "vim-ruby/vim-ruby", -- Is this really needed? 🤔

  "tpope/vim-bundler", -- bundle goodies (`gf` to go to bundled file, etc.)

  "vim-scripts/blockle.vim", -- toggle ruby block styles between {} and do/end

  "tpope/vim-endwise", -- "end" most "do"s wisely

  "jiangmiao/auto-pairs", -- auto complete matching pair
}
