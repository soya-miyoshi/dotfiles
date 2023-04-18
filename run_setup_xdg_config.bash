#!/bin/bash

source .xdg_helper.bash
set -x

for directory in `ls .dotconfig`
do
    ln -s $HOME/.dotconfig/nvim $XDG_CONFIG_HOME/$directory
done
