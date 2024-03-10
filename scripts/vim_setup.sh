#!/bin/bash

# Get the directory of the script
script_dir=$(dirname "$0") # get the relative path of this script
source_dir=$(dirname "$script_dir") # go up one level
source_dir_absolute=$(readlink -f $source_dir) # absolute path of source_dir

echo ""
echo "Vim basic setup"
echo "  Clone Vundle (Vim plugin manager)"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "  Vim color scheme 'mopkai'"
mkdir -p $HOME/.vim/colors # create dir if not already present
cp $source_dir_absolute/vim/colors/mopkai.vim $HOME/.vim/colors/

echo "  Install Vim plugins"
vim +PluginInstall +qall
