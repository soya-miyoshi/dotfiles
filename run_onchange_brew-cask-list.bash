#!/usr/bin/env bash
cat brew_cask_list.txt | xargs brew install --cask || true
