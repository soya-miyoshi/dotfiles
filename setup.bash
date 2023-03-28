#!/bin/bash

mkdir -p $(ghq root)/github.com/soya2222
ln -s $(ghq root)/github.com/soya2222/dotfiles $HOME
# ghq get zdharma-continuum/zinit

DOT_FILES=`ls .* | grep -E '^\..*' | grep -v '^.git:$' | grep -v '.swp$' | grep -v 'gitignore$'| sed -e 's/://g' | grep -v '^\.$' | grep -v '^\.\.$'`
echo $DOT_FILES

for file in ${DOT_FILES[@]}
do
    ln -s $HOME/dotfiles/$file $HOME/$file
done

DOT_CONFIGS=`ls ./dotconfig`
for folder in ${DOT_CONFIGS[@]}
do
    ln -s $HOME/dotfiles/dotconfig/$folder $HOME/.config/$folder
done

# for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md; do
#   ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
# done


