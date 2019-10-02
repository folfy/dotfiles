#!/usr/bin/env bash

main() {
	disable_f10
}


disable_f10() {
	echo "Patching: xfce4-terminal - disable F10"
	file="$HOME/.config/xfce4/terminal/accels.scm"
	cp "$file" "$file.bak"
	sed -i 's/^[^;]*F10.*/; \0/' "$file"

	if diff "$file.bak" "$file" &>/dev/null; then
		echo "No changes"
	else
		echo "Changes:"
		diff "$file.bak" "$file"
	fi
}

main "$@"
