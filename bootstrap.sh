#! /usr/bin/env bash

dirs="$(ls -d */)"
target="$HOME"

if ! [ -d ~/.vim ]; then
	# create as dir, avoid symlinking by stow
	mkdir ~/.vim
fi

# verbose dry-run
echo "Dry-run for setup to \"$target\" of dirs: "$dirs
stow -vn -t "$target" $dirs

if [ $? != 0 ]; then
	echo "There are conflicts which need to be resolved, cannot continue!"
	exit 1
fi
read -p "Enter to continue..."

stow -v -t "$target" $dirs
