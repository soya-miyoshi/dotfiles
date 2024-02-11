# Setup fzf
# ---------
export PATH="${PATH:+${PATH}:}${HOMEBREW_PREFIX}/opt/fzf/bin"

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
