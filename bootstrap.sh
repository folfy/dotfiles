#! /usr/bin/env bash

dirs="$(ls -d */)"
target="$HOME"

# verbose dry-run
echo "Dry-run for setup to \"$target\" of dirs: $dirs"
stow -vn -t "$target" $dirs 

read -p "Enter to continue..."

stow -v -t "$target" $dirs
