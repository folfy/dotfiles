#! /usr/bin/env bash

if [ "$1" == "-d" ]; then
	echo "WARNING: Delete mode"
	mode="-D"
elif [ "$1" == "-r" ]; then
	echo "WARNING: Restow mode"
	mode="-R"
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
if getent passwd | grep -q "ffritzer"; then
	echo "Office environment, removing target 'xfce-full'"
	dirs="$(echo "$dirs" | sed "s/xfce-full\/ \?//")"
else
	echo "Non-office environment, removing target 'office'"
	dirs="$(echo "$dirs" | sed "s/office\/ \?//")"
fi

# verbose dry-run
echo "Dry-run for setup to \"$target\" of dirs: "$dirs
stow -vn $mode -t "$target" $dirs

if [ $? != 0 ]; then
	if output=$(git status --porcelain) && [ -z "$output" ]; then
		# Working directory clean
		echo "There are conflicts, adopting repository - Check git status and resolve all issues afterwards!"
		modflag="--adopt"
	else
		# Uncommitted changes
		echo "There are conflicts and the local repository is not clean, cannot continue!"
		exit 1
		modflag=""
	fi
fi
read -p "Press enter to continue..."

stow -v $mode $modflag -t "$target" $dirs
