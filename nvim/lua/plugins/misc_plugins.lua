return {
  -- NOTE: Plugins can be added with a link (or for a github repo: "owner/repo" link).
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

  ------------------------------------------------------------------------------
  -- From my vimrc (replace with better alternatives when discovered)
  ------------------------------------------------------------------------------
  "tpope/vim-repeat", -- use . to repeat last command for plugins

  "moll/vim-bbye", -- Close buffer without closing the window using :Bdelete

  "tpope/vim-endwise", -- "end" most "do"s wisely

  "terryma/vim-multiple-cursors",

  "jiangmiao/auto-pairs", -- auto complete matching pair

  "christoomey/vim-tmux-navigator", -- Navigate Vim and Tmux panes/splits with the same key bindings

  -- "tpope/vim-rhubarb", -- Try gitlinker instead for GBrowse etc.

  -- "airblade/vim-gitgutter", -- show git changes in the margin (REPLACED BY Gitsigns)

  -- Tmux & co.
  "benmills/vimux", -- Interact with tmux from vim

  ------------------------------------------------------------------------------

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require("Comment").setup({})
  { "numToStr/Comment.nvim", opts = {} }, -- "gc" to comment visual regions/lines
}
