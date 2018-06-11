#! /usr/bin/env bash

dirs="$(ls -d */)"

# verbose dry-run
stow -vn $dirs

read -p "Enter to continue..."

stow -v $dirs
