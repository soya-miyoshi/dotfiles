#!/usr/bin/env bash
cat brew_list.txt | xargs brew install
cat pip_list.txt | xargs pip3 install 
