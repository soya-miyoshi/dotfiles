if [[ $(uname -m) == 'arm64' ]]; then
  eval $(/opt/homebrew/bin/brew shellenv) 
else
  eval "$(brew shellenv)"
fi

zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ ! "$line" =~ "^(cd|history|jj?|lazygit|la|ll|ls|rm|rmdir|trash)($| )" ]]
}

# zinitの読み込み
ZDOTDIR="$(ghq root)/github.com/soya2222/dotfiles"
source "$(ghq root)/github.com/zdharma-continuum/zinit/zinit.zsh"

# git-completionの読み込み
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/completion/git-completion.bash
autoload -Uz compinit && compinit


# git-promptの読み込み
source $ZDOTDIR/.zsh/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto
setopt PROMPT_SUBST ; PS1='%F{green}%n@%m%f: %F{cyan}%~%f %F{red}$(__git_ps1 "(%s)")%f
\$ '

# 現在のkubectlのコンテキスト等を追加
source ~/.kube-ps1/kube-ps1.sh
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
export PS1='$(kube_ps1)'$PS1

zinit wait lucid light-mode as'null' \
    atinit'source "$ZDOTDIR/.zshrc.lazy.sh"' \
    for 'zdharma-continuum/null'
