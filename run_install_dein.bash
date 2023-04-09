#!/usr/bin/env bash
# shellcheck source=./scripts/common.bash
source "xdg_helper.bash"

set -x
if [ -d "$XDG_DATA_HOME/dein/repos/github.com/Shougo/dein.vim" ]; then
    echo "dein.vim is already installed."
    git -C "$XDG_DATA_HOME/dein/repos/github.com/Shougo/dein.vim" pull

    echo "Updating dein.vim plugins..."
    nvim \
        -c ":call dein#update()" \
        -c ":call clap#installer#download_binary()" \
        -c ":q"
else
    echo "Installing dein.vim..."
    bash install_dein.sh

    echo "Installing dein.vim plugins..."
    nvim \
        -c ":call clap#installer#download_binary()" \
        -c ":q"
fi
