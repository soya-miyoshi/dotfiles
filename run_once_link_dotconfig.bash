#!/bin/bash

source .xdg_helper.bash
set -x

for directory in `ls .dotconfig`
do
    ln -s $HOME/.dotconfig/$directory $HOME/.config/$directory || true
done

find ~/.dotconfig/scripts/bin/ -type f -exec chmod 544 {} \;
