return {
  -- NOTE: Plugins can be added with a link (or for a github repo: "owner/repo" link).
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

  ------------------------------------------------------------------------------
  -- From my vimrc (replace with better alternatives when discovered)
  ------------------------------------------------------------------------------
  "moll/vim-bbye", -- Close buffer without closing the window using :Bdelete
  "tpope/vim-repeat", -- use . to repeat last command for plugins
  "terryma/vim-multiple-cursors",

  -- Tmux & co.
  "christoomey/vim-tmux-navigator", -- Navigate Vim and Tmux panes/splits with the same key bindings
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

  { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      -- require("mini.ai").setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()

      require("mini.tabline").setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require "mini.statusline"
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%3l:%-2v"
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Add indentation lines even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    -- See `:help ibl`
    main = "ibl",
    opts = {},
  },
}
