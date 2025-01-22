#!/bin/bash

sudo apt update
sudo apt install -y --fix-broken \
	curl \
	git \
	make \
	zsh

chsh -s $(which zsh)

echo "Shell bootstrap complete. Reboot to apply."

