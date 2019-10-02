#!/usr/bin/env bash

main() {
	disable_f10
	xfce4_panel
}

add_patch() {
	echo " - $1"
	patch="$patch; $2"
}

show_changes() {
	file="$1"
	if diff "$file.bak" "$file" &>/dev/null; then
		echo "No changes"
	else
		echo "Changes:"
		diff "$file.bak" "$file"
	fi
}

disable_f10() {
	echo "Patching: xfce4-terminal - disable F10"
	file="$HOME/.config/xfce4/terminal/accels.scm"
	cp "$file" "$file.bak"
	sed -i 's/^[^;]*F10.*/; \0/' "$file"
	show_changes "$file"
}

xfce4_panel() {
	echo "Patching: xfce4-panel - multiple patches"
	file="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
	cp "$file" "$file.bak"

	patch=""
	add_patch "show clock with seconds" 's/\( %H:%M\)"/\1:%S"/'
	echo " - display on primary monitor"
	if ! grep "output-name" "$file" &>/dev/null; then
		patch="$patch; "'/autohide-behavior/a     <property name="output-name" type="string" value="Primary"/>'
	fi

	sed -i "$patch" "$file"
	show_changes "$file"

	echo
	echo "Add system load plugin manually:"
	echo "~/.config/xfce4/panel/systemload-13.rc"
	echo "~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
	echo '<property name="plugin-13" type="string" value="systemload"/>'
}

main "$@"
