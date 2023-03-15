# set -o vi
setopt inc_append_history
setopt share_history
bindkey -e

alias reload="source ~/.zshrc"
alias v="nvim"
alias vim="nvim"
alias less="nvim -R"
alias orca='java -jar ~/.dotbin/monsiaj-loader-2.0.30-all.jar'

eval "$(saml2aws --completion-script-zsh)"

#navi

__navi_search() {
    LBUFFER="$(navi --print --query="$LBUFFER")"
    zle reset-prompt
}
__navi_atload() {
    export NAVI_CONFIG="$XDG_CONFIG_HOME/navi/config.yaml"

    zle -N __navi_search
    bindkey '^N' __navi_search
}
zinit wait lucid light-mode as'program' from'gh-r' for \
    atload'__navi_atload' \
    @'denisidoro/navi'

# rbenvの設定
eval "$(rbenv init -)"

# cluster update用のgithub token
source $HOME/private-dotfiles/.tokens

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# スペースで始まるコマンドはHistoryに入れない
export HISTCONTROL=ignoreboth
export HISTSIZE=10000

# AWSのデフォルトプロファイルを設定
source $HOME/private-dotfiles/.aws-default-profile
# simlimkを表示する
alias mylink="find $HOME -type l -maxdepth 1"
alias myconfig="find $HOME/.config -type l"
alias rmlink="find $HOME -type l -maxdepth 1 | xargs -I% unlink %"

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
alias alc="saml2aws login --skip-prompt --role='arn:aws:iam::057575985710:role/freee-sso-admin' --session-duration 10800 --profile='saml-cfo'"
alias ale="saml2aws login --skip-prompt --role='arn:aws:iam::148248004276:role/freee-sso-admin' --session-duration 21600 --profile='saml-e2e'"
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

case "$OSTYPE" in
    linux*)
        (( ${+commands[wslview]} )) && alias open='wslview'

        if (( ${+commands[win32yank.exe]} )); then
            alias pp='win32yank.exe -i'
            alias p='win32yank.exe -o'
        elif (( ${+commands[xsel]} )); then
            alias pp='xsel -bi'
            alias p='xsel -b'
        fi
    ;;
    msys)
        alias cmake='command cmake -G"Unix Makefiles"'
        alias pp='cat >/dev/clipboard'
        alias p='cat /dev/clipboard'
    ;;
    darwin*)
        alias pp='pbcopy'
        alias p='pbpaste'
        alias chrome='open -a "Google Chrome"'
        (( ${+commands[gdate]} )) && alias date='gdate'
        (( ${+commands[gls]} )) && alias ls='gls --color=auto'
        (( ${+commands[gmkdir]} )) && alias mkdir='gmkdir'
        (( ${+commands[gcp]} )) && alias cp='gcp -i'
        (( ${+commands[gmv]} )) && alias mv='gmv -i'
        (( ${+commands[grm]} )) && alias rm='grm -i'
        (( ${+commands[gdu]} )) && alias du='gdu'
        (( ${+commands[ghead]} )) && alias head='ghead'
        (( ${+commands[gtail]} )) && alias tail='gtail'
        (( ${+commands[gsed]} )) && alias sed='gsed'
        (( ${+commands[ggrep]} )) && alias grep='ggrep'
        (( ${+commands[gfind]} )) && alias find='gfind'
        (( ${+commands[gdirname]} )) && alias dirname='gdirname'
        (( ${+commands[gxargs]} )) && alias xargs='gxargs'
    ;;
esac

zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ ! "$line" =~ "^(cd|jj?|lazygit|la|ll|ls|rm|rmdir)($| )" ]]
}

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
bindkey '^p' peco-src

tmux source-file ~/.tmux.conf

# Gitリポジトリを列挙する
widget::ghq::source() {
    local session color icon green="GGG" blue="BBB" reset="RRR" checked="CCC" unchecked="UUU"
    local sessions=($(tmux list-sessions -F "#S" 2>/dev/null))

    ghq list | sed "s/github.com\///" | sort | while read -r repo; do
        session="${repo//[:. ]/-}"
        color="$blue"
        icon="$unchecked"
        if (( ${+sessions[(r)$session]} )); then
            color="$green"
            icon="$checked"
        fi
        printf "%s\n" "$repo"
    done
}
# GitリポジトリをFZFで選択する
widget::ghq::select() {
    local root="$(ghq root)"
    widget::ghq::source | fzf --exit-0 --preview="fzf-preview-git ${(q)root}/{+2}" --preview-window="right:60%" | cut -d' ' -f2-
}
# FZFで選択されたGitリポジトリにTmuxセッションを立てる
widget::ghq::session() {
    local selected="$(widget::ghq::select)"
    if [ -z "$selected" ]; then
        return
    fi

    local repo_dir="$(ghq list --exact --full-path "$selected")"
    local session_name="${selected//[:. ]/-}"
    echo $session_name

    if [ -z "$TMUX" ]; then
        # Tmuxの外にいる場合はセッションにアタッチする
        BUFFER="tmux new-session -A -s ${(q)session_name} -c ${(q)repo_dir}"
        cd $repo_dir
        zle accept-line
    elif [ "$(tmux display-message -p "#S")" = "$session_name" ] && [ "$PWD" != "$repo_dir" ]; then
        # 選択されたGitリポジトリのセッションにすでにアタッチしている場合はGitリポジトリのルートディレクトリに移動する
        BUFFER="cd ${(q)repo_dir}"
        zle accept-line
    else
        # 別のTmuxセッションにいる場合はセッションを切り替える
        tmux new-session -d -s "$session_name" -c "$repo_dir" 2>/dev/null
        tmux switch-client -t "$session_name"
    fi
    zle -R -c # refresh screen
}
zle -N widget::ghq::session

# C-g で呼び出せるようにする
bindkey "^G" widget::ghq::session

zinit wait lucid blockf light-mode for \
    @'zsh-users/zsh-autosuggestions' \
    @'zsh-users/zsh-completions' \
    @'zdharma-continuum/fast-syntax-highlighting' \
    @'b4b4r07/enhancd'
