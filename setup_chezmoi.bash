#!/bin/bash

# source "$(dirname "$0")/xdg_helper.bash"

# ghq get zdharma-continuum/zinit
# DOT_FILES=`ls .* | grep -E '^\..*' | grep -v '^.git:$' | grep -v '.swp$' | grep -v 'gitignore$'| sed -e 's/://g' | grep -v '^\.$' | grep -v '^\.\.$'`
# echo $DOT_FILES

# for file in ${DOT_FILES[@]}
# do
#     cp -r $file ~
#     chezmoi add ~/$file
# done

# for directory in `ls dot_dotconfig`
# do
#     ln -s `pwd`/dot_dotconfig/$directory ~/.config/$directory
# done
# DOT_CONFIGS=`ls ./dotconfig`
# for folder in ${DOT_CONFIGS[@]}
# do
#     ln -s $HOME/dotfiles/dotconfig/$folder $HOME/.config/$folder
# done

# for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md; do
#   ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
# done
