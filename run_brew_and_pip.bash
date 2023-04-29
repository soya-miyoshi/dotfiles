#!/usr/bin/env bash
cat brew_list.txt | xargs brew install
cat brew_cask_list.txt | xargs brew install --cask 
cat pip_list.txt | xargs pip3 install 

