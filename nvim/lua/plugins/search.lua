return { -- Fuzzy Finder (files, lsp, etc)
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable "make" == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown(),
      },
    }
    -- Enable telescope extensions, if they are installed
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    -- Clone the default Telescope configuration
    local vimgrep_arguments = { unpack(require("telescope.config").values.vimgrep_arguments) }
    -- I want to search in hidden/dot files.
    table.insert(vimgrep_arguments, "--hidden")
    table.insert(vimgrep_arguments, "--no-ignore-vcs")

    require("telescope").setup {
      defaults = {
        file_ignore_patterns = {
          ".*node_modules/.*",
          ".git/.*",
        },
        vimgrep_arguments = vimgrep_arguments,
      },
    }

    local builtin = require "telescope.builtin"
    local utils = require "telescope.utils"

    -- Find files
    vim.keymap.set("n", "<leader>ff", function() -- Most commonly used (so repeating key makes it easier)
      builtin.git_files { show_untracked = true, hidden = true }
    end, { desc = "Project Files" })
    vim.keymap.set("n", "<leader>fr", function()
      builtin.oldfiles { only_cwd = true, hidden = true }
    end, { desc = "[R]ecent Files" })
    vim.keymap.set("n", "<leader>fh", function()
      builtin.find_files { cwd = utils.buffer_dir(), hidden = true }
    end, { desc = "[H]ere" })
    vim.keymap.set("n", "<leader>fd", function() -- Shortcut for searching my dotfiles repo
      builtin.find_files { cwd = "$HOME/dotfiles_mac" }
    end, { desc = "[D]otfiles" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[B]uffers currently open" })
    vim.keymap.set("n", "<leader>fa", function()
      builtin.find_files { only_cwd = true, hidden = true }
    end, { desc = "[A]ll files in PWD" })

    -- Fuzzy find other things
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search [K]eymaps" })
    vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "Search [T]elescope" })
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search [H]elp" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search current [W]ord" })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search by [G]rep" })
    vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search [D]iagnostics" })
    vim.keymap.set("n", "<leader>s.", builtin.resume, { desc = "Search Resume ('.' is for repeat)" })
    vim.keymap.set("n", "<leader>/", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = "[/] Fuzzily search in current buffer" })
    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      }
    end, { desc = "[S]earch [/] in Open Files" })
  end,
}
