set -o vi

setopt inc_append_history
setopt share_history

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(saml2aws --completion-script-zsh)"

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# rbenvの設定
eval "$(rbenv init -)"

# zinitの読み込み
source "$(ghq root)/github.com/zdharma-continuum/zinit/zinit.zsh"

# cluster update用のgithub token
source $HOME/private-dotfiles/.tokens 

# スペースで始まるコマンドはHistoryに入れない
export HISTCONTROL=ignoreboth
export HISTSIZE=10000

# AWSのデフォルトプロファイルを設定
source $HOME/private-dotfiles/.aws-default-profile

# git-promptの読み込み
source ~/.zsh/completion/git-prompt.sh

# git-completionの読み込み
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/completion/git-completion.bash
autoload -Uz compinit && compinit

# simlimkを表示する
alias ll=$HOME/.list_links.sh

# プロンプトのオプション表示設定
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

# kubectx
export PATH=~/.kubectx:$PATH

# goenv のパス
# brew install goenv した
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

# lsec2
export PATH="${LSEC2_ROOT:-$HOME}/lsec2/bin:$PATH"
# krew
export PATH="${KREW_ROOT:-$HOME}/.krew/bin:$PATH"
# aqua
# export PATH="${HOME}/.local/share/aquaproj-aqua/bin:$PATH"
# unset AQUA_GLOBAL_CONFIG=${HOME}/sre-docs/external/aws/eks/aqua.yaml

# AWS login 
alias al="saml2aws login --skip-prompt --session-duration=10000 --force"
alias alq="saml2aws login --skip-prompt --force"

# Docker build を並列で実行する設定
export DOCKER_BUILDKIT=1

# kubectl の補完設定
alias k="kubectl"
#source <(kubectl completion zsh)

# terraform のalias
alias t="terraform"

alias g="git"

# helm の補完設定
alias h="helm"
alias hf="helmfile"

# nvm の設定
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# pecoの活用1
# ctrl + r で過去に実行したコマンドを選択できるようにする。
function peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^g' peco-src

