#eval "$(/opt/homebrew/bin/brew shellenv)"
#eval "$(saml2aws --completion-script-bash)"
## スペースで始まるコマンドはHistoryに入れない
#export HISTCONTROL=ignoreboth
#
## completionを追加
#[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
#
#GIT_PS1_SHOWDIRTYSTATE=true
#GIT_PS1_SHOWSTASHSTATE=true
#GIT_PS1_SHOWUNTRACKEDFILES=true
#GIT_PS1_COMPRESSSPARSESTATE=true
#GIT_PS1_SHOWUPSTREAM=true
#
#setopt PROMPT_SUBST ; PS1='%F{green}@%m%f: %F{cyan}%~%f %F{red}$(__git_ps1 "(%s)")%f \$ '
#
## goenv のパス
## brew install goenv した
#export GOENV_ROOT="$HOME/.goenv"
#export PATH="$GOENV_ROOT/bin:$PATH"
#eval "$(goenv init -)"
#
## lsec2
#export PATH="${LSEC2_ROOT:-$HOME}/lsec2/bin:$PATH"
#
## krew
#export PATH="${KREW_ROOT:-$HOME}/.krew/bin:$PATH"
#
#
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
