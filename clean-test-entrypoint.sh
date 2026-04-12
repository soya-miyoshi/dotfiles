#!/usr/bin/env bash
# Runs INSIDE the clean-room test container.
# - Installs chezmoi from get.chezmoi.io
# - Runs `chezmoi init --source /dotfiles --apply` (no GitHub clone)
# - Asserts dotfiles are correctly placed
# - Optionally skips Homebrew install for fast smoke testing (SKIP_BREW=1)
set -euo pipefail

DOTFILES_SRC="${DOTFILES_SRC:-/dotfiles}"
SKIP_BREW="${SKIP_BREW:-0}"

bold() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }

bold "Environment"
echo "  user:      $(id -un)"
echo "  HOME:      $HOME"
echo "  source:    $DOTFILES_SRC"
echo "  SKIP_BREW: $SKIP_BREW"

[ -d "$DOTFILES_SRC" ] || fail "$DOTFILES_SRC not mounted (bind-mount your dotfiles repo there)"

bold "Installing chezmoi"
mkdir -p "$HOME/bin"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/bin"
export PATH="$HOME/bin:$PATH"
chezmoi --version

# Both modes skip secret managers (no op/bw available in CI).
# SKIP_BREW=1 additionally short-circuits Homebrew install for a fast smoke.
export CHEZMOI_NO_SECRETS=1
if [ "$SKIP_BREW" = "1" ]; then
    export CI=1
fi

bold "chezmoi init --source $DOTFILES_SRC"
chezmoi --source "$DOTFILES_SRC" init --no-tty --promptDefaults

bold "chezmoi apply"
chezmoi --source "$DOTFILES_SRC" apply --no-tty --verbose

bold "Assertions"

[ -f "$HOME/.zshrc" ]          || fail ".zshrc not installed"
ok ".zshrc installed"

[ -f "$HOME/.zshrc.lazy.sh" ]  || fail ".zshrc.lazy.sh not installed"
ok ".zshrc.lazy.sh installed"

[ -f "$HOME/.tmux.conf" ]      || fail ".tmux.conf not installed"
ok ".tmux.conf installed"

[ -f "$HOME/.gitconfig" ]      || fail ".gitconfig not installed"
ok ".gitconfig installed"

[ -f "$HOME/.tokens" ]         || fail ".tokens not created"
perms=$(stat -c '%a' "$HOME/.tokens")
[ "$perms" = "600" ]           || fail ".tokens has mode $perms (expected 600)"
ok ".tokens has mode 600"

[ -L "$HOME/.config/git" ]     || fail ".config/git symlink not created"
[ -L "$HOME/.config/nvim" ]    || fail ".config/nvim symlink not created"
[ -L "$HOME/.config/scripts" ] || fail ".config/scripts symlink not created"
ok ".config/{git,nvim,scripts} symlinks created"

[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ] || fail "zinit not installed"
ok "zinit installed"

# zsh syntax sanity-check on the rendered config files
zsh -n "$HOME/.zshrc"          || fail ".zshrc has zsh syntax errors"
zsh -n "$HOME/.zshrc.lazy.sh"  || fail ".zshrc.lazy.sh has zsh syntax errors"
ok "zsh syntax OK"

# Repo metadata files must NOT leak into HOME (chezmoiignore check)
for f in Dockerfile Makefile README.md MIGRATION_PLAN.md docker-compose.yml setup.sh; do
    if [ -e "$HOME/$f" ]; then
        fail "$f leaked into HOME (chezmoiignore is broken)"
    fi
done
ok "repo metadata correctly excluded from HOME"

if [ "$SKIP_BREW" = "1" ]; then
    bold "SKIP_BREW=1: Homebrew checks skipped"
else
    bold "Homebrew checks"
    [ -x /home/linuxbrew/.linuxbrew/bin/brew ] || fail "brew not installed at /home/linuxbrew/.linuxbrew/bin/brew"
    ok "brew installed"

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Check each expected command. Don't bail on first failure — collect all
    # missing packages so the user sees the full picture.
    missing=()
    for cmd in nvim fzf gh jq fd rg direnv tmux ghq sops age tfenv; do
        if command -v "$cmd" >/dev/null 2>&1; then
            ok "$cmd in PATH"
        else
            printf '  \033[31m✗\033[0m %s NOT in PATH\n' "$cmd"
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo
        echo "Missing commands: ${missing[*]}"
        echo
        echo "Last 80 lines of brew install output (search for 'FAIL'):"
        echo "------------------------------------------------------------"
        # The run_once script's output is captured by chezmoi and printed during
        # apply, so it's already in the docker run output above. Re-print any
        # FAIL lines from brew's log if available.
        find "$HOME/.cache/Homebrew/Logs" -name '*.log' 2>/dev/null | head -5 | while read -r log; do
            echo "--- $log ---"
            tail -10 "$log"
        done
        echo "------------------------------------------------------------"
        fail "${#missing[@]} expected command(s) missing after brew install"
    fi
fi

bold "Idempotency: re-running apply must produce no diff"
chezmoi --source "$DOTFILES_SRC" apply --no-tty >/tmp/apply2.log 2>&1 || {
    cat /tmp/apply2.log
    fail "second apply errored"
}
diff_output=$(chezmoi --source "$DOTFILES_SRC" diff --no-tty 2>&1 || true)
if [ -n "$diff_output" ]; then
    echo "$diff_output"
    fail "second apply produced a diff — not idempotent"
fi
ok "idempotent (empty diff on re-apply)"

bold "All checks passed ✓"
