# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/dotfiles_mac/oh-my-zsh/custom

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# TEST 'e*' and onwards - PPJ
ZSH_THEME="ppj_wedisagree"

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
# COMPLETION_WAITING_DOTS="true"

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
plugins=(git bundler zsh-syntax-highlighting history-substring-search)

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='vim'
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
bindkey '^Z' fancy-ctrl-z

# Vim mode for shell
bindkey -v

# bind ctrl-r to invoke command history
bindkey '^R' history-incremental-search-backward

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# set aliases
# clear screen AND the scroll-back buffer (equivalent to Windows 'cls' command)
alias cls='printf "\ec"'

# Tmuxinator (https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh)
source /usr/local/share/zsh/site-functions/_tmuxinator

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

# spring aliases
alias sc='bin/spring rails console'
alias sr='bin/spring rake'

# workflow aliases
alias fs='foreman start'
alias sync='bundle install && rake db:migrate'
alias syncm='git checkout master && git pull && bundle install && rake db:migrate'
alias bk='echo y | git buildkite'

# git aliases
alias git=hub
alias gls='git status && git branch'
alias use_latest_master='git fetch && git rebase origin/master'
alias FORCE_push_and_build='git push --force && echo y | git buildkite'
alias delete_merged_branches='git branch --merged master | grep -v "master" | xargs git branch -d'

# vim
alias vime='vim -u essential.vim'

# emacs (https://superuser.com/a/317687)
emacs() { /Applications/Emacs.app/Contents/MacOS/Emacs "$@" &  }

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# postgres
export PG_USER=${USER}

# fuzzy finder fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zsh-syntax-highlighting
source /Users/ppj/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
