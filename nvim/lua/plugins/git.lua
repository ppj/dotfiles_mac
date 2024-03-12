return {
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gg", ":Git<CR>", { desc = "[G]it Status" }) -- git status
      vim.keymap.set("n", "<leader>gd", ":Gdiff<CR>", { desc = "[G]it [D]iff current file" }) -- git diff current file
      vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "[G]it [B]lame" }) -- git blame current file
      vim.keymap.set("n", "<leader>gl", ":Git pull<CR>", { desc = "[G]it [P]ull" }) -- git pull
    end,
  },
  {
    "linrongbin16/gitlinker.nvim", -- GBrowse and links
    config = function()
      require("gitlinker").setup()
      vim.keymap.set({ "n", "v" }, "<leader>gy", ":GitLink default_branch<CR>", { desc = "[G]it cop[y] URL  main-branch" })
      vim.keymap.set({ "n", "v" }, "<leader>gm", ":GitLink! default_branch<CR>", { desc = "[G]it browse [m]ain-branch" })
      vim.keymap.set({ "n", "v" }, "<leader>gc", ":GitLink<CR>", { desc = "[G]it cop[y] URL blob" })
      vim.keymap.set({ "n", "v" }, "<leader>go", ":GitLink!<CR>", { desc = "[G]it br[o]wse blob" })
    end,
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        -- Actions
        map("n", "<leader>gp", gs.preview_hunk, { desc = "[P]review hunk" })
        map("n", "<leader>gt", gs.toggle_current_line_blame, { desc = "[T]oggle line blame" })
      end,
    },
  },
}
