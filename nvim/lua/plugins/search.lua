-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of help_tags options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
return { -- Fuzzy Finder (files, lsp, etc)
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { -- If encountering errors, see telescope-fzf-native README for install instructions
      "nvim-telescope/telescope-fzf-native.nvim",

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = "make",

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable "make" == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "kelly-lin/telescope-ag" },

    -- Useful for getting pretty icons, but requires special font.
    --  If you already have a Nerd Font, or terminal set up with fallback fonts
    --  you can enable this
    { "nvim-tree/nvim-web-devicons" },
  },
  -- You can put your default mappings / updates / etc. in here
  --  All the info you're looking for is in `:help telescope.setup()`
  --
  -- defaults = {
  --   mappings = {
  --     i = { ["<c-enter>"] = "to_fuzzy_refine" },
  --   },
  -- },
  -- pickers = {}
  config = function()
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown(),
      },
    }
    -- Enable telescope extensions, if they are installed
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")
    pcall(require("telescope").load_extension, "ag")

    -- See `:help telescope.builtin`
    local builtin = require "telescope.builtin"
    local utils = require "telescope.utils"

    -- Find files
    vim.keymap.set("n", "<leader>or", function()
      builtin.oldfiles { only_cwd = true, hidden = true }
    end, { desc = "[R]ecent Files" })

    vim.keymap.set("n", "<leader>oo", function()
      -- See :help telescope.builtin.git_files() for more options
      builtin.git_files { show_untracked = true, hidden = true }
    end, { desc = "Project Files" })

    vim.keymap.set("n", "<leader>oh", function()
      builtin.find_files { cwd = utils.buffer_dir(), hidden = true }
    end, { desc = "[H]ere" })

    vim.keymap.set("n", "<leader>od", function() -- Shortcut for searching my dotfiles repo
      builtin.find_files { cwd = "$HOME/dotfiles_mac" }
    end, { desc = "[D]otfiles" })

    vim.keymap.set("n", "<leader>ob", builtin.buffers, { desc = "[B]uffers" })

    vim.keymap.set("n", "<leader>of", function()
      builtin.find_files { only_cwd = true, hidden = true }
    end, { desc = "[F]iles in PWD" })

    -- Search in project using telescope-ag extension
    vim.keymap.set("v", "<C-s>", "y:Ag <C-r>0<Esc>", { remap = true, desc = "Search selected in project" })
    vim.keymap.set("n", "<C-s>", "yiw:Ag <C-r>0<Esc>", { remap = true, desc = "Search word in project" })

    -- Fuzzy find other things
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search [K]eymaps" })
    vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "Search [T]elescope" })
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search [H]elp" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search current [W]ord" })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search by [G]rep" })
    vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search [D]iagnostics" })
    vim.keymap.set("n", "<leader>s.", builtin.resume, { desc = "Search Resume ('.' is for repeat)" })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set("n", "<leader>/", function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- Also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      }
    end, { desc = "[S]earch [/] in Open Files" })
  end,
}