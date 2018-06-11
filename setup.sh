#! /usr/bin/env bash

sudo <<EOF
	# wireshark
	apt-get install wireshark
	usermod -a -G wireshark folfy

	# utils
	apt-get install curl
EOF
