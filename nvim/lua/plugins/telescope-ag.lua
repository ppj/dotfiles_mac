  return { -- Ag (The Silver Searcher) for search in project
    "kelly-lin/telescope-ag",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      pcall(require("telescope").load_extension, "ag")

      -- Ag keymaps to search word in the project
      vim.keymap.set("v", "<C-s>", "y:Ag <C-r>0<Esc>", { remap = true, desc = "Search selected in project" })
      vim.keymap.set("n", "<C-s>", "yiw:Ag <C-r>0<Esc>", { remap = true, desc = "Search word in project" })
    end,
  }

