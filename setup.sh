#!/bin/bash

DOT_FILES=`ls .* | grep -E '^\..*' | grep -v '^.git:$' | grep -v '.swp$' | grep -v 'gitignore$'| sed -e 's/:/\//g' | grep -v '^\.\/$' | grep -v '^\.\.\/$'`
echo $DOT_FILES

for file in ${DOT_FILES[@]}
do
    echo 'Link ${HOME}/${files} to ${HOME}/dotfiles/${file}'
    ln -s $HOME/dotfiles/$file $HOME/$file
done

