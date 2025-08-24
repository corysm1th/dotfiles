#=-=-=-= Targets

.PHONY: zsh \
	aws \
	font \
	fzf \
	go \
	hx \
	kuberntes \
	minikube \
	neovim \
	lazyvim \
	rust \
	tmux \
	wezterm \
	python3

CRI_UTIL := nerdctl
ZSH := "/bin/zsh"
ZSH_CONFIG := $(HOME)/.config/zsh
GO := /usr/local/go/bin/go
RUST := $(HOME)/.cargo/bin/rustc
PYTHON_VERSION := 3.13
DL_DIR := $(HOME)/Downloads
LAZYGIT_VERSION := $(shell curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \rg -Po '"tag_name": *"v\K[^"]*')

$(HOME)/.config:
	mkdir $(HOME)/.config

$(DL_DIR):
	mkdir -p $(DL_DIR)


#=-=-=-= JetBrains Mono Font w/ NerdFonts =-=-=-=

# font: $(DL_DIR)
# 	curl -L	https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
# 		-o $(DL_DIR)/JetBrainsMono.zip
# 	sudo unzip $(DL_DIR)/JetBrainsMono.zip -d /usr/local/share/fonts


#=-=-=-= Go =-=-=-=

go: $(HOME)/go/bin/gopls $(HOME)/go/bin/dlv
	install .config/zsh/10-go.zsh $(HOME)/.config/zsh/

$(HOME)/go/bin/gopls:
	go install golang.org/x/tools/gopls@latest || echo "Install go from macOS package"

$(HOME)/go/bin/dlv:
	go install github.com/go-delve/delve/cmd/dlv@latest


#=-=-=-= junegunn/fzf =-=-=-=

fzf: $(ZSH_CONFIG)
	./fzf_install.sh
	install .config/zsh/30-fzf.zsh $(ZSH_CONFIG)/30-fzf.zsh


#=-=-=-= Neovim =-=-=-=
luarocks:
	brew install luarocks

lazygit:
	brew install lazygit

neovim:
	-rm -Rf $(HOME)/Downloads/nvim-linux-x86_64.tar.gz
	curl -L https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz -o ${HOME}/Downloads/nvim-linux-x86_64.tar.gz
	-sudo rm -Rf /usr/local/nvim-linux-x86_64
	sudo tar -xzf ${HOME}/Downloads/nvim-linux-x86_64.tar.gz -C /usr/local/
	-ln -s /usr/local/nvim-linux-x86_64/bin/nvim $(HOME)/.local/bin/nvim

lazyvim: luarocks lazygit
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

zsh: $(ZSH_CONFIG) \
	$(ZSH_CONFIG)/20-zsh-vim-mode.plugin.zsh \
	fzf \
	$(HOME)/go/bin/powerline-go \
	$(ZSH_CONFIG)/99-zsh-syntax-highlighting.zsh
	install .zshrc $(HOME)/.zshrc
	install env.example $(HOME)/.env.example

$(ZSH_CONFIG):
	mkdir -p $(HOME)/.config/zsh

$(ZSH_CONFIG)/20-zsh-vim-mode.plugin.zsh:
	curl -L https://github.com/jeffreytse/zsh-vi-mode/raw/refs/heads/master/zsh-vi-mode.zsh \
		-o $(ZSH_CONFIG)/20-zsh-vi-mode.plugin.zsh


#=-=-=-= Zsh Helpers =-=-=-=

aws:
	-rm -f $(ZSH_CONFIG)/72-aws.zsh
	install .config/zsh/72-aws.zsh $(ZSH_CONFIG)/72-aws.zsh

kubernetes:
	-rm -f $(ZSH_CONFIG)/60-kubernetes.zsh
	install .config/zsh/60-kubernetes.zsh $(ZSH_CONFIG)/60-kubernetes.zsh
	
minikube:
	-rm -f $(ZSH_CONFIG)/60-minikube.zsh
	install .config/zsh/60-minikube.zsh $(ZSH_CONFIG)/60-minikube.zsh

macos:
	-rm -f $(ZSH_CONFIG)/90-macos.zsh
	install .config/zsh/90-macos.zsh $(ZSH_CONFIG)/90-macos.zsh


#=-=-=-= Helix =-=-=-=

hx:
	$(shell $(PWD)/helix_install.sh)


#=-=-=-= Rust =-=-=-=

rust: $(RUST)
	install .config/zsh/41-rust.zsh $(HOME)/.config/zsh/41-rust.zsh

rust/clean:
	rm -Rf $(RUST)

$(RUST):
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


#=-=-=-= Wezterm =-=-=-=

wezterm: $(HOME)/.config/zsh/15-wezterm.zsh
	$(shell which /Applications/WezTerm.app/Contents/MacOS/wezterm && mkdir $(HOME)/.config/wezterm)
	install .config/wezterm/wezterm.lua $(HOME)/.config/wezterm/

$(HOME)/.config/zsh/15-wezterm.zsh:
	install .config/zsh/15-wezterm.zsh $(HOME)/.config/zsh/


#=-=-=-= Tmux =-=-=-=

## TODO
# LC_CTYPE=UTF-8 <- TODO: figure out where to put this

tmux: /usr/bin/tmux \
	${HOME}/.config/tmux/plugins/tpm
	install .config/tmux/tmux.conf ${HOME}/.config/tmux/tmux.conf
	install .config/tmux/onedark.tmux ${HOME}/.config/tmux/onedark.tmux
	$(HOME)/.config/tmux/plugins/tpm/bin/install_plugins

# Homebrew has the latest stable tmux
/usr/bin/tmux:
	brew install tmux

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


