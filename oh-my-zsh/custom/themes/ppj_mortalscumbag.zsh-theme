function my_git_prompt() {
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(my_current_branch)$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function my_current_branch() {
  echo $(current_branch || echo "(no branch)")
}

function ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg_bold[red]%}(ssh) "
  fi
}

local ret_status="%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})%?%{$reset_color%}"
PROMPT=$'\n%~ $(my_git_prompt)\n$ '
RPROMPT='$(ssh_connection)%{$fg_bold[green]%}%n@%m%{$reset_color%}'

ZSH_THEME_PROMPT_RETURNCODE_PREFIX="%{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_PREFIX="$fg[white]|%{$fg_bold[yellow]%} "
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[magenta]%}↑"
ZSH_THEME_GIT_PROMPT_STAGED=" %{$limegreen%}✚ "
ZSH_THEME_GIT_PROMPT_UNSTAGED="⚡ "
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$hotpink%}✭ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}✕"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
