#!/bin/bash

sudo apt update
sudo apt install -y --fix-broken \
    bat \
	curl \
    fd-find \
	feh \
	git \
	gnupg2 \
	htop \
	iperf3 \
	jq \
	neofetch \
	make \
    ripgrep \
	sysstat \
	unzip \
	wget \
	zsh

chsh -s $(which zsh)

mkdir -p ${HOME}/.local/bin || true

ln -s $(which fdfind) ~/.local/bin/fd
ln -s $(which batcat) ~/.local/bin/bat

echo "Shell bootstrap complete. Reboot to apply."

