#!/usr/bin/env bash
# Install zinit to the standard location if missing.
# This removes the previous fragile dependency on `ghq root`.
set -euo pipefail

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [ -d "$ZINIT_HOME/.git" ]; then
    echo "[install_zinit] already installed at $ZINIT_HOME"
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo "[install_zinit] git not installed, skipping"
    exit 0
fi

mkdir -p "$(dirname "$ZINIT_HOME")"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
echo "[install_zinit] installed."
