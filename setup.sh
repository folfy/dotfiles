#! /usr/bin/env bash

sudo <<EOF
	apt-get install wireshark
	usermod -a -G wireshark folfy
EOF
