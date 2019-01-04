#! /usr/bin/env bash

if [ "$1" == "-d" ]; then
	echo "WARNING: Delete mode"
	mode="-D"
else
	#default mode (create links)
	mode=""
fi

dirs="$(ls -d */)"
target="$HOME"

if ! [ -d ~/.vim ]; then
	# create as dir, avoid symlinking by stow
	mkdir ~/.vim
fi

# check for office environment
if dig atviesu0005 | grep -q "AUTHORITY: 1"; then
	echo "Office environment, keeping office"
else
	echo "Non-office environment, removing office-target"
	dirs="$(echo "$dirs" | sed "s/office\/ \?//")"
fi

# verbose dry-run
echo "Dry-run for setup to \"$target\" of dirs: "$dirs
stow -vn $mode -t "$target" $dirs

if [ $? != 0 ]; then
	if output=$(git status --porcelain) && [ -z "$output" ]; then
		# Working directory clean
		echo "There are conflicts, adopting repository - Check git status and resolve all issues afterwards!"
	else 
		# Uncommitted changes
		echo "There are conflicts and the local repository is not clean, cannot continue!"
	fi
	
fi
read -p "Press enter to continue..."

stow -v $mode -t "$target" $dirs
