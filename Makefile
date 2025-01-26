#=-=-=-= Targets

.PHONY: zsh \
	alacritty \
	font \
	fzf \
	go \
	hx \
	rust \
	tmux \
	python3

# Verified:
# zsh
# go
# font
# hx

ALACRITTY := "/usr/local/bin/alacritty"
ZSH := "/usr/bin/zsh"
ZSH_CONFIG := $(HOME)/.config/zsh
GO_SRC := go1.23.5.linux-amd64.tar.gz
GO := /usr/local/go/bin/go
RUST := $(HOME)/.cargo/bin/rustc
PYTHON_VERSION := 3.13
DL_DIR := $(HOME)/Downloads

$(HOME)/.config:
	mkdir $(HOME)/.config

$(DL_DIR):
	mkdir -p $(DL_DIR)


#=-=-=-= JetBrains Mono Font w/ NerdFonts =-=-=-=

font: $(DL_DIR)
	curl -L	https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
		-o $(DL_DIR)/JetBrainsMono.zip 
	sudo unzip $(DL_DIR)/JetBrainsMono.zip -d /usr/local/share/fonts


#=-=-=-= Go =-=-=-=

go: $(GO)

$(HOME)/$(GO_SRC):
	curl -L -o $(HOME)/$(GO_SRC) https://go.dev/dl/$(GO_SRC)

$(GO): $(HOME)/$(GO_SRC)
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf $(HOME)/$(GO_SRC)
	cp .config/zsh/10-go.zsh $(ZSH_CONFIG)/10-go.zsh


#=-=-=-= junegunn/fzf =-=-=-=

fzf: $(ZSH_CONFIG)
	./fzf_install.sh
	install .config/zsh/30-fzf.zsh $(ZSH_CONFIG)/30-fzf.zsh


#=-=-=-= Zsh =-=-=-=

$(HOME)/go/bin/powerline-go: $(GO)
	$(GO) install github.com/justjanne/powerline-go@latest
	install .config/zsh/50-powerline-go.zsh $(ZSH_CONFIG)/50-powerline-go.zsh

$(ZSH_CONFIG)/99-zsh-syntax-highlighting.zsh:
	-rm -Rf ${HOME}/.config/zsh-syntax-highlighting 
	git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/.config/zsh-syntax-highlighting
	install .config/zsh/99-zsh-syntax-highlighting.zsh $(ZSH_CONFIG)/99-zsh-syntax-highlighting.zsh

zsh: $(ZSH) \
	$(ZSH_CONFIG) \
	$(ZSH_CONFIG)/20-zsh-vim-mode.plugin.zsh \
	fzf \
	$(HOME)/go/bin/powerline-go \
	$(ZSH_CONFIG)/99-zsh-syntax-highlighting.zsh
	install .zshrc $(HOME)/.zshrc
	install env.example $(HOME)/.env.example

$(ZSH):
	sudo apt install -y zsh

$(ZSH_CONFIG):
	mkdir -p $(HOME)/.config/zsh

$(ZSH_CONFIG)/20-zsh-vim-mode.plugin.zsh:
	curl -L https://github.com/jeffreytse/zsh-vi-mode/raw/refs/heads/master/zsh-vi-mode.zsh \
		-o $(ZSH_CONFIG)/20-zsh-vi-mode.plugin.zsh


#=-=-=-= Helix =-=-=-=

hx:
	$(shell $(PWD)/helix_install.sh)


#=-=-=-= Rust =-=-=-=

rust: $(RUST)

$(RUST):
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


#=-=-=-= Alacritty =-=-=-=

alacritty: $(ALACRITTY)

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

#=-=-=-= Tmux =-=-=-=

tmux: $(HOME)/.tmux.conf $(HOME)/.tmux/plugins/tpm

/usr/bin/tmux:
	sudo apt install -y tmux

$(HOME)/.tmux/plugins/tpm: 
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

$(HOME)/.tmux.conf: /usr/bin/tmux
	cp .tmux.conf $(HOME)/.tmux.conf
	$(HOME)/.tmux/plugins/tpm/scripts/install_plugins.sh

#=-=-=-= Python3 =-=-=-=

$(HOME)/.pyenv:
	curl https://pyenv.run | bash

/usr/bin/python3: $(HOME)/.pyenv
	sudo apt install -y make build-essential libssl-dev zlib1g-dev \
		libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
		libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
	-$(HOME)/.pyenv/bin/pyenv install $(PYTHON_VERSION)
	-$(HOME)/.pyenv/bin/pyenv global $(PYTHON_VERSION)

python3: /usr/bin/python3


#=-=-=-= REPL Environment =-=-=-=

build:
	nerdctl build -t snbox .

run:
	#nerdctl run --rm -it --user 1000:1000 -v ./:/home/ubuntu/dotfiles snbox "TERM=xterm-256color /usr/bin/zsh" 
	nerdctl run --rm -it --user 1000:1000 -v ./:/home/ubuntu/dotfiles snbox env TERM="xterm-256color" /usr/bin/zsh
