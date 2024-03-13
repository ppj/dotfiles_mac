return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    require("neo-tree").setup {
      window = {
        mappings = { -- diff navigation consistent with gitsigns & vimdiff
          ["[c"] = "prev_git_modified",
          ["[g"] = "nop",
          ["]c"] = "next_git_modified",
          ["]g"] = "nop",
        },
      },
    }

    -- mappings
    vim.keymap.set("n", "<leader>n", ":Neotree filesystem reveal left toggle<CR>", { desc = "[N]eoTree Toggle" })
  end,
}
