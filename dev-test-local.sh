#!/usr/bin/env bash
# Test chezmoi against this LOCAL /workspace from inside the dev container.
#
# - Uses an isolated HOME so the real /home/node is untouched
# - CI mode: skips Homebrew install and secret managers (1P/BW)
# - Installs chezmoi to /tmp on demand (no sudo needed)
#
# Usage:
#   ./dev-test-local.sh                  # run apply
#   ./dev-test-local.sh --diff           # show diff vs current isolated HOME
#   ./dev-test-local.sh --shell          # drop into a zsh with the isolated HOME
#   ./dev-test-local.sh --clean          # wipe isolated HOME and chezmoi binary
#
# Environment overrides:
#   ISOLATED_HOME   default: /tmp/chezmoi-dev-test
#   SOURCE_DIR      default: /workspace
#   CHEZMOI_BIN_DIR default: /tmp/chezmoi-bin

set -euo pipefail

ISOLATED_HOME="${ISOLATED_HOME:-/tmp/chezmoi-dev-test}"
SOURCE_DIR="${SOURCE_DIR:-/workspace}"
CHEZMOI_BIN_DIR="${CHEZMOI_BIN_DIR:-/tmp/chezmoi-bin}"
CHEZMOI="$CHEZMOI_BIN_DIR/chezmoi"

cmd="${1:-apply}"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
info() { printf '  %s\n' "$*"; }

ensure_chezmoi() {
    if [ -x "$CHEZMOI" ]; then
        return
    fi
    bold "==> Installing chezmoi to $CHEZMOI_BIN_DIR"
    mkdir -p "$CHEZMOI_BIN_DIR"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_BIN_DIR" >/dev/null
    info "$($CHEZMOI --version)"
}

reset_home() {
    rm -rf "$ISOLATED_HOME"
    mkdir -p "$ISOLATED_HOME"
}

run_chezmoi() {
    HOME="$ISOLATED_HOME" \
    CI=1 \
    CHEZMOI_NO_SECRETS=1 \
    "$CHEZMOI" --source "$SOURCE_DIR" "$@"
}

case "$cmd" in
    --clean|clean)
        bold "==> Cleaning up"
        rm -rf "$ISOLATED_HOME" "$CHEZMOI_BIN_DIR"
        info "removed $ISOLATED_HOME"
        info "removed $CHEZMOI_BIN_DIR"
        ;;

    --shell|shell)
        ensure_chezmoi
        bold "==> Opening shell with HOME=$ISOLATED_HOME"
        info "Run 'chezmoi --source $SOURCE_DIR <cmd>' inside."
        info "Type 'exit' to leave."
        HOME="$ISOLATED_HOME" \
        CI=1 \
        CHEZMOI_NO_SECRETS=1 \
        PATH="$CHEZMOI_BIN_DIR:$PATH" \
        zsh
        ;;

    --diff|diff)
        ensure_chezmoi
        if [ ! -d "$ISOLATED_HOME/.config/chezmoi" ]; then
            bold "==> No prior init found, running init first"
            run_chezmoi init --no-tty --promptDefaults
        fi
        bold "==> chezmoi diff"
        run_chezmoi diff --no-tty
        ;;

    --help|-h|help)
        sed -n '2,18p' "$0"
        ;;

    apply|--apply|"")
        ensure_chezmoi
        bold "==> Resetting isolated HOME"
        reset_home
        info "HOME=$ISOLATED_HOME"
        info "source=$SOURCE_DIR"
        info "CI=1, CHEZMOI_NO_SECRETS=1"

        echo
        bold "==> chezmoi init"
        run_chezmoi init --no-tty --promptDefaults

        echo
        bold "==> chezmoi apply"
        run_chezmoi apply --no-tty --verbose

        echo
        bold "==> Files placed in isolated HOME"
        find "$ISOLATED_HOME" -maxdepth 2 -mindepth 1 \
            \! -path "$ISOLATED_HOME/.cache*" \
            \! -path "$ISOLATED_HOME/.local/share/zinit*" \
            -printf '  %M  %p\n' | sort

        echo
        bold "==> Permission check"
        if [ -f "$ISOLATED_HOME/.tokens" ]; then
            perms=$(stat -c '%a' "$ISOLATED_HOME/.tokens")
            if [ "$perms" = "600" ]; then
                info "✓ ~/.tokens has mode 600"
            else
                info "✗ ~/.tokens has mode $perms (expected 600)"
                exit 1
            fi
        else
            info "✗ ~/.tokens not created"
            exit 1
        fi

        echo
        bold "==> Done"
        info "Inspect: $ISOLATED_HOME"
        info "Re-run:  $0"
        info "Cleanup: $0 --clean"
        ;;

    *)
        echo "unknown command: $cmd"
        echo "see: $0 --help"
        exit 2
        ;;
esac
