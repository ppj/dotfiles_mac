#!/bin/bash

# Get the directory of the script
script_dir=$(dirname "$0") # get the relative path of this script
source_dir=$(dirname "$script_dir") # go up one level
source_dir_absolute=$(readlink -f $source_dir) # absolute path of source_dir

# List of files to symlink
files_to_symlink=("gitconfig" "vimrc" "zshrc" "tmux.conf" "starship.toml")
echo "Symlinking ... "

# Create symbolic links for specified files (using the absolute path of the source file)
for file in "${files_to_symlink[@]}"; do
  echo "  $source_dir_absolute/$file to $HOME/.$file"
  ln -sf "$source_dir_absolute/$file" "$HOME/.$file"
done

############################################################################################
create_deep_symlink() {
  local dir=$1
  local target_dir="$HOME/.config"

  echo "  Replicating $dir directory structure under $target_dir if it doesn't exist"
  find $dir -type d ! -name ".git*" -exec mkdir -p "$target_dir/{}" \;
  find $dir -type f ! -name ".*" -exec echo "    $PWD/{}" to "$target_dir/{}" \;
  find $dir -type f ! -name ".*" -exec ln -sf "$PWD/{}" "$target_dir/{}" \;
}

old_dir=$(PWD)
cd $source_dir_absolute # set the present working directory

create_deep_symlink "nvim"
create_deep_symlink "ghostty"

cd $old_dir # cd back to the previous working directory

############################################################################################
echo "Run the vim_setup.sh script for setting up Vim"
