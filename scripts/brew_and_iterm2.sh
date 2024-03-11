#!/bin/bash

source ./scripts/display_banner.sh

display_banner "Installing brew (assuming 'curl' is pre-installed). Ref: https://brew.sh/"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

display_banner "Installing iTerm2"
brew install iterm2
