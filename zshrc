# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# TEST 'e*' and onwards - PPJ
ZSH_THEME="random"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git bundler zsh-syntax-highlighting history-substring-search z zsh-autosuggestions)

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='nvim'
# else
#   export EDITOR='mvim'
# fi
export USE_EDITOR=$EDITOR
export VISUAL=$EDITOR

# User Ctrl-z to switch back to Vim
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey -M viins '^Z' fancy-ctrl-z

# Vim mode for shell
bindkey -v

# bind ctrl-r to invoke command history
bindkey '^R' history-incremental-search-backward

# set aliases
# colorful ls (install with `brew install eza`)
alias els='eza --tree'

# aliases for Tmux
alias tmux='tmux -2'
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tls='tmux ls'
alias tkill='tmux kill-session -t'

# convenience aliases for editing configs
alias ev='vim ~/dotfiles_mac/vimrc'
alias et='vim ~/dotfiles_mac/tmux.conf'
alias ez='vim ~/dotfiles_mac/zshrc'

# git aliases
alias gls='git status && git branch'
alias use_latest_master='git fetch && git rebase origin/$(git_main_branch)'
alias delete_merged_branches='git branch --merged $(git_main_branch) | grep -v "$(git_main_branch)" | xargs git branch -d'

# Better way to delete merged branches (asks for confirmation)
clean_merged_branches() {
    echo "Fetching latest changes..."
    git fetch --prune

    echo "Finding merged branches to delete..."

    # Get list of merged branches, excluding main/master and current branch
    branches_to_delete=$(git branch --merged main | grep -v -E "(main|master|\*)" | xargs)

    if [ -z "$branches_to_delete" ]; then
        echo "No merged branches to delete."
        return 0
    fi

    echo "The following merged branches will be deleted:"
    echo "$branches_to_delete"

    # Prompt for confirmation
    read -p "Are you sure you want to delete these branches? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Delete the branches
        echo "$branches_to_delete" | xargs -n 1 git branch -d
        echo "Merged branches deleted successfully!"
    else
        echo "Operation cancelled."
    fi
}

# vim & nvim (Neovim)
alias vime='vim -u essential.vim'
alias nvim_reset='rm -rf ~/.local/state/nvim ~/.local/share/nvim ~/.config/nvim/lazy-lock.json'

# Multiple Neovim distros (needs fzf - brew install fzf)
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim" # git clone https://github.com/LazyVim/starter "{XDG_CONFIG_HOME:-$HOME/.config}"/LazyVim
alias nvim-kick="NVIM_APPNAME=kickstart nvim" # git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/kickstart
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim" # git clone https://github.com/AstroNvim/template "${XDG_CONFIG_HOME:-$HOME/.config}"/AstroNvim

function nvims() {
  items=("default" "kickstart" "LazyVim" "AstroNvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

bindkey -s ^a "nvims\n" # convenience shortcut to launch different distros of nvim using Ctrl+a

# emacs (https://superuser.com/a/317687)
emacs() { /Applications/Emacs.app/Contents/MacOS/Emacs "$@" &  }

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# postgres
export PG_USER=${USER}

# fuzzy finder fzf
eval "$(fzf --zsh)"

# brew path
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/openssl@3/bin:$PATH"

export NODE_ENV=development

# Kafka
export KAFKA_OPTS=-Djava.security.auth.login.config=/users/prasanna.joshi/kafka/users_jaas.conf
export DEV_BROKERS=b-2.platform.0mgply.c11.kafka.us-west-2.amazonaws.com:9096,b-1.platform.0mgply.c11.kafka.us-west-2.amazonaws.com:9096
export STAGING_US_BROKERS=b-2.platform.eyefok.c6.kafka.us-west-2.amazonaws.com:9096,b-1.platform.eyefok.c6.kafka.us-west-2.amazonaws.com:9096
export PROD_US_BROKERS=b-2.platform.ydtozs.c8.kafka.us-west-2.amazonaws.com:9096,b-1.platform.ydtozs.c8.kafka.us-west-2.amazonaws.com:9096
export PROD_EU_BROKERS=b-1.platform.yfis3v.c1.kafka.eu-west-1.amazonaws.com:9096,b-2.platform.yfis3v.c1.kafka.eu-west-1.amazonaws.com:9096

export DEV_ZOOKEEPER=z-3.platform.0mgply.c11.kafka.us-west-2.amazonaws.com:2181,z-1.platform.0mgply.c11.kafka.us-west-2.amazonaws.com:2181,z-2.platform.0mgply.c11.kafka.us-west-2.amazonaws.com:2181
export STAGING_US_ZOOKEEPER=z-1.platform.eyefok.c6.kafka.us-west-2.amazonaws.com:2181,z-2.platform.eyefok.c6.kafka.us-west-2.amazonaws.com:2181,z-3.platform.eyefok.c6.kafka.us-west-2.amazonaws.com:2181
export PROD_US_ZOOKEEPER=z-2.platform.ydtozs.c8.kafka.us-west-2.amazonaws.com:2181,z-3.platform.ydtozs.c8.kafka.us-west-2.amazonaws.com:2181,z-1.platform.ydtozs.c8.kafka.us-west-2.amazonaws.com:2181
export PROD_EU_ZOOKEEPER=z-2.platform.yfis3v.c1.kafka.eu-west-1.amazonaws.com:2181,z-1.platform.yfis3v.c1.kafka.eu-west-1.amazonaws.com:2181,z-3.platform.yfis3v.c1.kafka.eu-west-1.amazonaws.com:2181
export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"

fpath=(/Users/prasanna.joshi/.granted/zsh_autocomplete/assume/ $fpath)

fpath=(/Users/prasanna.joshi/.granted/zsh_autocomplete/granted/ $fpath)

export GRANTED_ENABLE_AUTO_REASSUME=true

alias assume="source assume"

# List EC2 instances and start an SSM session (Ref: https://cultureamp.slack.com/archives/CR5375Y3Z/p1729649030762239)
start_aws_session() {
  INSTANCE_ID=$(
    aws ec2 describe-instances \
      --query "Reservations[*].Instances[*].[InstanceId, State.Name, Tags[?Key=='Name'].Value | [0]]" \
      --output table |
      fzf --header "Select an EC2 Instance" |
      awk '{print $2}' |
      sed 's/|$//'
  )
  if [ -n "$INSTANCE_ID"  ]; then
    echo "Starting SSM session with instance ID: $INSTANCE_ID"
    aws ssm start-session --target "$INSTANCE_ID"
  else
    echo "No instance selected."
  fi
}

# Setup starship prompt
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.starship.toml

# asdf path takes precedence over system path (ensures asdf installed ruby is used by default)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# direnv hook
eval "$(direnv hook zsh)"

# ensure that global devbox tools are configured
eval "$(devbox global shellenv)"

# use asdf installed ruby version as default global


# The next line was added by hotel, leave it at the bottom of this file
source /Users/prasanna.joshi/.config/hotel/config.zsh

export PATH="$HOME/.local/bin:$PATH"
