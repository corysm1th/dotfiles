$(HOME)/.config:
	mkdir $(HOME)/.config

fonts:
	$(shell sudo cp jetbrains_mono_nerd_font/posix/* /usr/local/share/fonts/)

$(HOME)/.tmux/plugins/tpm:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

$(HOME)/.tmux.conf:
	cp .tmux.conf $(HOME)/.tmux.conf

$(HOME)/.config/bspwm: $(HOME)/.config
	cp -r bspwm $(HOME)/.config/

$(HOME)/.config/sxhkd:
	cp -r sxhkd $(HOME)/.config/

$(HOME)/.config/rofi:
	cp -r rofi $(HOME)/.config/

$(HOME)/.config/polybar:
	cp -r polybar $(HOME)/.config/

$(HOME)/.oh-my-zsh:
	$(shell sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")

$(HOME)/.oh-my-zsh/custom/themes/powerlevel10k:
	mkdir -p $(HOME)/.oh-my-zsh/custom/themes
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $(HOME)/.oh-my-zsh/custom/themes/powerlevel10k

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

$(HOME)/.p10k.zsh: $(HOME)/.oh-my-zsh/custom/themes/powerlevel10k
	cp .p10k.zsh $(HOME)/
	cp $(HOME)/.zshrc $(HOME)/.zshrc.dotfiles_backup
	cp .zshrc $(HOME)/

$(HOME)/.config/alacritty:
	cp -r alacritty $(HOME)/.config/

.PHONY: install fonts alacritty tmux zsh

install: $(HOME)/.config \
	fonts \
	$(HOME)/.config/bspwm $(HOME)/.config/sxhkd $(HOME)/.config/rofi $(HOME)/.config/polybar \
	zsh tmux alacritty

alacritty: $(HOME)/.config/alacritty

tmux: $(HOME)/.tmux.conf $(HOME)/.tmux/plugins/tpm

zsh: $(HOME)/.oh-my-zsh \
	$(HOME)/.env.example \
	$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
	$(HOME)/.oh-my-zsh/custom/plugins/zsh-vi-mode \
	$(HOME)/.p10k.zsh
