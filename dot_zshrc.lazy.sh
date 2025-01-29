# set -o vi
setopt inc_append_history
setopt share_history
bindkey -e

alias reload="source ~/.zshrc"
alias c='chezmoi'
alias v="nvim"
alias vim="vim"
alias less="vim -R"
alias orca='java -jar ~/.dotbin/monsiaj-loader-2.0.30-all.jar'
alias encs3='java -jar ~/.dotbin/amazon-s3-encryption-cli-client-1.0.1-alpha.jar'
alias exportenv='export $(cat .env | xargs -L 1)'
alias g='git'
alias gs='git status'
# add modified file using `git status | grep modified | awk '{print $2}' | xargs git add`
alias gam='git add $(git status | grep modified | awk '\''{print $2}'\'')'
alias gco='git checkout'
alias gc='git commit'
alias gcm='git commit -m'
alias gd='git checkout develop'
alias ca='chezmoi apply'
alias gr='git fetch origin develop && git rebase origin/develop'
# alias t=~/.local/share/aquaproj-aqua/bin/terraform
alias tpt='t plan --target'
alias gn='git checkout develop && git pull && git checkout -b'
alias codechezoi='code ~/.local/share/chezmoi'

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

# private-dotfiles
source $HOME/private-dotfiles/.tokens
source $HOME/private-dotfiles/dot_zshrc.private
export PATH="${HOME}/private-dotfiles/scripts:$PATH"

# scripts
export PATH="${HOME}/.dotconfig/scripts/bin:$PATH"

# java 
export PATH="/usr/local/opt/openjdk/bin:$PATH"

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


# goenv のパス
# brew install goenv した
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"


# Docker build を並列で実行する設定
export DOCKER_BUILDKIT=1

# kubectl の補完設定
alias k="kubectl"
#source <(kubectl completion zsh)

# helm の補完設定
alias h="helm"
alias hf="helmfile"

# nvm の設定
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# aqua でインストールされたものを優先的に使う設定
# export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"

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

### FZF fzf-preview-git で必要
# export FZF_DEFAULT_OPTS='--reverse --border --ansi --bind="ctrl-d:print-query,ctrl-p:replace-query"'
export FZF_DEFAULT_OPTS='--border --ansi --bind="ctrl-d:print-query,ctrl-p:replace-query"'
export FZF_DEFAULT_COMMAND='fd --hidden --color=always'

# Gitリポジトリを列挙する
widget::ghq::source() {
    local session color icon green="\e[32m" blue="\e[34m" reset="\e[m" checked="✔" unchecked="✖"
    local sessions=($(tmux list-sessions -F "#S" 2>/dev/null))

    ghq list | sort | while read -r repo; do
        session="${repo//[:. ]/-}"
        color="$blue"
        icon="$unchecked"
        if (( ${+sessions[(r)$session]} )); then
            color="$green"
            icon="$checked"
        fi
        printf "$color$icon %s$reset\n" "$repo"
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

# Gitブランチを列挙する
widget::git::source() {
    git branch --all --color=always | sed 's/^[ *]*//;s/ ->.*//;s/HEAD/HEAD /' | sort | while read -r branch; do
        printf "%s\n" "$branch"
    done
}

# GitブランチをFZFで選択する
widget::git::select() {
    widget::git::source | fzf --exit-0 | cut -d' ' -f2-
}

# FZFで選択されたGitブランチにswitchする
widget::git::checkout() {
    printf "git switch "
    local selected="$(widget::git::select)"
    if [ -n "$selected" ]; then
        BUFFER="git switch ${(q)selected}"
        zle accept-line
    fi
}

# C-e で呼び出せるようにする
zle -N widget::git::checkout
bindkey "^s" widget::git::checkout

zinit wait lucid blockf light-mode for \
    @'zsh-users/zsh-autosuggestions' \
    @'zdharma-continuum/fast-syntax-highlighting'
    # @'zsh-users/zsh-completions' \
    # @'zdharma-continuum/fast-syntax-highlighting'

zinit ice wait lucid blockf
zinit light mrjohannchang/zsh-interactive-cd

zinit ice wait lucid blockf
zinit light babarot/enhancd
# nvm use を cd 後に実行する
export ENHANCD_HOOK_AFTER_CD="([ -f '.nvmrc' ] && nvm use)"

zinit ice wait lucid blockf
zinit light Aloxaf/fzf-tab
