set -o vi
setopt inc_append_history
setopt share_history

alias reload="source ~/.zshrc"

eval "$(saml2aws --completion-script-zsh)"

# rbenvの設定
eval "$(rbenv init -)"

# cluster update用のgithub token
source $HOME/private-dotfiles/.tokens

# スペースで始まるコマンドはHistoryに入れない
export HISTCONTROL=ignoreboth
export HISTSIZE=10000

# AWSのデフォルトプロファイルを設定
source $HOME/private-dotfiles/.aws-default-profile

# simlimkを表示する
alias mylink="find $HOME -type l -maxdepth 1"
alias unlink="find . -type l -maxdepth 1 | xargs -I% unlink %"

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

zinit wait lucid blockf light-mode for \
    @'zsh-users/zsh-autosuggestions' \
    @'zsh-users/zsh-completions' \
    @'zdharma-continuum/fast-syntax-highlighting' \
    @'b4b4r07/enhancd'
