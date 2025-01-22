RUST := $(HOME)/.cargo/bin/rustc
ALACRITTY := "/usr/local/bin/alacritty"
FONT := "/usr/local/share/fonts/JetBrains Mono Regular Nerd Font Complete Mono.ttf"
ZSH := "/usr/bin/zsh"
GO_SRC := go1.19.3.linux-amd64.tar.gz
POWERLINE_GO_VERSION := v1.22.1
GO := /usr/local/go/bin/go
PYTHON_VERSION := 3.10

$(HOME)/.config:
	mkdir $(HOME)/.config

# JetBrains Mono Font w/ NerdFonts

$(FONT):
	$(shell sudo cp jetbrains_mono_nerd_font/posix/* /usr/local/share/fonts/)

# Go

$(HOME)/$(GO_SRC):
	curl -L -o $(HOME)/$(GO_SRC) https://go.dev/dl/$(GO_SRC)

$(GO): $(HOME)/$(GO_SRC)
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf $(HOME)/$(GO_SRC)

# Zsh

$(HOME)/go/bin/powerline-go:
	mkdir -p $(HOME)/go/bin
	curl -L -o $(HOME)/go/bin/powerline-go https://github.com/justjanne/powerline-go/releases/download/$(POWERLINE_GO_VERSION)/powerline-go-linux-amd64
	sudo chmod +x $(HOME)/go/bin/powerline-go

zsh: $(ZSH) \
	$(HOME)/.oh-my-zsh/oh-my-zsh.sh \
	$(HOME)/.zshrc \
	$(HOME)/.env.example \
	$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
	$(HOME)/.oh-my-zsh/custom/plugins/zsh-vi-mode \
	$(HOME)/go/bin/powerline-go

$(ZSH):
	sudo apt install -y zsh

$(HOME)/.oh-my-zsh/oh-my-zsh.sh:
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh 
	rm -f $(HOME)/.zshrc

$(HOME)/.zshrc:
	cp .zshrc $(HOME)/.zshrc

$(HOME)/.env.example:
	cp env.example $(HOME)/.env.example

$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting:
	cd $(HOME) && \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
		$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

$(HOME)/.oh-my-zsh/custom/plugins/zsh-vi-mode:
	cd $(HOME) && \
	git clone https://github.com/jeffreytse/zsh-vi-mode \
		$(HOME)/.oh-my-zsh/custom/plugins/zsh-vi-mode

# Rust

$(RUST):
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Alacritty

$(ALACRITTY): $(HOME)/.config/alacritty
	sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
	-mkdir -p $(HOME)/src/github.com/alacritty
	-cd $(HOME)/src/github.com/alacritty && git clone https://github.com/alacritty/alacritty.git
	-cd $(HOME)/src/github.com/alacritty/alacritty && $(HOME)/.cargo/bin/cargo build --release
	-cd $(HOME)/src/github.com/alacritty/alacritty && \
		sudo cp target/release/alacritty /usr/local/bin/ && \
		sudo tic -xe alacritty,alacritty-direct extra/alacritty.info && \
		sudo cp target/release/alacritty /usr/local/bin && \
		sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg && \
		sudo desktop-file-install extra/linux/Alacritty.desktop && \
		sudo update-desktop-database

$(HOME)/.config/alacritty:
	cp -r alacritty $(HOME)/.config/

# Tmux

/usr/bin/tmux:
	sudo apt install -y tmux

$(HOME)/.tmux/plugins/tpm: 
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

$(HOME)/.tmux.conf: /usr/bin/tmux
	cp .tmux.conf $(HOME)/.tmux.conf
	$(HOME)/.tmux/plugins/tpm/scripts/install_plugins.sh

# Python3

$(HOME)/.pyenv:
	curl https://pyenv.run | bash

/usr/bin/python3: $(HOME)/.pyenv
	sudo apt install -y make build-essential libssl-dev zlib1g-dev \
		libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
		libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
	-$(HOME)/.pyenv/bin/pyenv install $(PYTHON_VERSION)
	-$(HOME)/.pyenv/bin/pyenv global $(PYTHON_VERSION)

# Targets

.PHONY: all font go zsh rust alacritty tmux utils podman

all: $(HOME)/.config \
	python3 \
	utils \
	podman \
	font \
	go \
	zsh \
	rust \
	alacritty \
	tmux

python3: /usr/bin/python3

font: $(FONT)

go: $(GO)

rust: $(RUST)

alacritty: $(ALACRITTY)

tmux: $(HOME)/.tmux.conf $(HOME)/.tmux/plugins/tpm

# Install apt distro utils

utils:
	sudo apt install -y feh htop gnupg2 curl wget sysstat iperf3 neofetch

# Podman / Docker Compose

podman:
	sudo apt install -y podman podman-docker docker-compose

## REPL Environment

build:
	nerdctl build -t snbox .

run:
	nerdctl run --rm -it --user 1000:1000 -v ./:/home/ubuntu/dotfiles snbox

