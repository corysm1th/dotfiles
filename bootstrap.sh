#!/bin/bash

sudo apt update
sudo apt install -y --fix-broken \
	curl \
	feh \
	git \
	gnupg2 \
	htop \
	iperf3 \
	jq \
	neofetch \
	make \
	sysstat \
	unzip \
	wget \
	zsh

chsh -s $(which zsh)

mkdir -p ${HOME}/.local/bin || true

echo "Shell bootstrap complete. Reboot to apply."

