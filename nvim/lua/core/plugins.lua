local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
  use "wbthomason/packer.nvim"
  use { "catppuccin/nvim", as = "catppuccin" }
  use "nvim-tree/nvim-tree.lua"
  use {
    "nvim-telescope/telescope.nvim", tag = "0.1.5",
    requires = { {"nvim-lua/plenary.nvim"} },
  }
  use {
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons", opt = true }
  }
  use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate"})

  ---------------------------------------------------------------------------------------------------------------------
  -- These are from my vimrc. Use better nvmim alternatives when discovered.
  ---------------------------------------------------------------------------------------------------------------------
  use "tpope/vim-surround" 
  use "tpope/vim-repeat" -- use . to repeat last command for plugins
  use "moll/vim-bbye" -- Close buffer without closing the window using :Bdelete
  use "tpope/vim-endwise" -- 'end' most 'do's wisely
  use "terryma/vim-multiple-cursors"
  use "jiangmiao/auto-pairs" -- auto complete matching pair
  use "henrik/vim-indexed-search" -- search count display & more search customisations
  use "Yggdroot/indentLine" -- display vertical line at each indent location
  use "christoomey/vim-tmux-navigator" -- Navigate Vim and Tmux panes/splits with the same key bindings
  -- Git
  use "tpope/vim-fugitive"
  -- use "tpope/vim-rhubarb.git" -- Fails to install in neovim
  use "airblade/vim-gitgutter" -- show git changes in the margin
  -- Ruby (& Rails)
  use "tpope/vim-rails"
  use "benmills/vimux" -- Interact with tmux from vim
  use "skalnik/vim-vroom" -- Ruby test runner that works well with tmux
  ---------------------------------------------------------------------------------------------------------------------

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
