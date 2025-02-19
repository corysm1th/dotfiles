#=-=-=-= Targets

.PHONY: zsh \
	alacritty \
	font \
	fzf \
	go \
	hx \
	neovim \
	lazyvim \
	rust \
	tmux \
	python3

CRI_UTIL := nerdctl
ALACRITTY := "/usr/local/bin/alacritty"
ZSH := "/usr/bin/zsh"
ZSH_CONFIG := $(HOME)/.config/zsh
GO_SRC := go1.23.5.linux-amd64.tar.gz
GO := /usr/local/go/bin/go
RUST := $(HOME)/.cargo/bin/rustc
PYTHON_VERSION := 3.13
DL_DIR := $(HOME)/Downloads
LAZYGIT_VERSION := $(shell curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')

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

go: $(GO) $(HOME)/go/bin/gopls $(HOME)/go/bin/dlv

$(HOME)/$(GO_SRC):
	curl -L -o $(HOME)/$(GO_SRC) https://go.dev/dl/$(GO_SRC)

$(GO): $(HOME)/$(GO_SRC)
	
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf $(HOME)/$(GO_SRC)
	cp .config/zsh/10-go.zsh $(ZSH_CONFIG)/10-go.zsh

$(HOME)/go/bin/gopls:
	go install golang.org/x/tools/gopls@latest

$(HOME)/go/bin/dlv:
	go install github.com/go-delve/delve/cmd/dlv@latest


#=-=-=-= junegunn/fzf =-=-=-=

fzf: $(ZSH_CONFIG)
	./fzf_install.sh
	install .config/zsh/30-fzf.zsh $(ZSH_CONFIG)/30-fzf.zsh


#=-=-=-= Neovim =-=-=-=
clang:
	sudo apt update && sudo apt install -y clang

luarocks:
	sudo apt update && sudo apt install -y luarocks

lazygit:
	curl -Lo $(HOME)/Downloads/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar -C $(HOME)/.local/bin -xzf $(HOME)/Downloads/lazygit.tar.gz lazygit

neovim:
	-rm -Rf $(HOME)/Downloads/nvim-linux-x86_64.tar.gz
	curl -L https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz -o ${HOME}/Downloads/nvim-linux-x86_64.tar.gz	
	-sudo rm -Rf /usr/local/nvim-linux-x86_64
	sudo tar -xzf ${HOME}/Downloads/nvim-linux-x86_64.tar.gz -C /usr/local/
	-ln -s /usr/local/nvim-linux-x86_64/bin/nvim $(HOME)/.local/bin/nvim
	
lazyvim: clang luarocks lazygit
	-rm -Rf $(HROME)/.local/share/nvim
	-rm -Rf $(HOME)/.local/state/nvim
	-rm -Rf $(HOME)/.cache/nvim
	git clone https://github.com/LazyVim/starter $(HOME)/.config/nvim
	rm -Rf $(HOME)/.config/nvim/.git
	nvim --headless "+Lazy! sync" +qa

lazyextras:
	install .config/nvim/lazyvim.json $(HOME)/.config/nvim/
	install .config/nvim/lua/plugins/onedark.lua $(HOME)/.config/nvim/lua/plugins/onedark.lua 
	nvim --headless "+Lazy! sync" +qa


#=-=-=-= Zsh =-=-=-=

$(HOME)/go/bin/powerline-go: $(GO)
	$(GO) install github.com/justjanne/powerline-go@latest
	install .config/zsh/50-powerline-go.zsh $(ZSH_CONFIG)/50-powerline-go.zsh
	install .config/zsh/pl_colors.json $(ZSH_CONFIG)/pl_colors.json

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

## TODO
# LC_CTYPE=UTF-8 <- TODO: figure out where to put this

tmux: /usr/bin/tmux \
	${HOME}/.config/tmux/plugins/tpm
	install .config/tmux/tmux.conf ${HOME}/.config/tmux/tmux.conf
	install .config/tmux/onedark.tmux ${HOME}/.config/tmux/onedark.tmux
	$(HOME)/.config/tmux/plugins/tpm/scripts/install_plugins.sh

/usr/bin/tmux:
	sudo apt install -y tmux

${HOME}/.config/tmux/plugins/tpm:
	mkdir -p ${HOME}/.config/tmux/plugins
	git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

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
	$(CRI_UTIL) build -t snbox .

run:
	$(CRI_UTIL) run --rm -it --user 1000:1000 -v ${PWD}:/home/ubuntu/dotfiles snbox env TERM="xterm-256color" /usr/bin/zsh

