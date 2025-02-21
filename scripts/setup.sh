#!/bin/bash

source ./scripts/display_banner.sh

display_banner "Installing basics for terminal (zsh, tmux)"
brew install zsh tmux

display_banner "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

display_banner "Installing tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

display_banner "Installing git and hub"
brew install git hub 

display_banner "Installing editors (vim, neovim)"
brew install vim nvim

display_banner "Installing search tools (fzf, ag, ripgrep, fd)"
echo "(ripgrep and fd are required for telescope.nvim's grep)"
brew install fzf ag ripgrep fd

display_banner "Installing hack-nerd-font"
brew tap homebrew/cask-fonts
brew install font-hack-nerd-font
echo "Add the HackNerdFont to your iTerm2 profile (Text tab)"

display_banner "Installing starship prompt"
brew install starship

display_banner "Installing zsh-autosuggestions custom plugin"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

display_banner "Installing zsh-syntax-highlighting custom plugin"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

display_banner "Installing eza (for tree mode and colourful ls)"
brew install eza

