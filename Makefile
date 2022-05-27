$(HOME)/.config:
	mkdir $(HOME)/.config

$(HOME)/.tmux/plugins/tpm:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

$(HOME)/.tmux.conf:
	cp .tmux.conf $(HOME) /

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

$(HOME)/.env.example:
	cp env.example $(HOME)/.env.example

$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting:
	cd $(HOME) && \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
		$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting)

$(HOME)/.oh-my-zsh/custom/plugins/zsh-vi-mode:
	cd $(HOME) && \
	git clone https://github.com/jeffreytse/zsh-vi-mode \
		$(HOME)/.oh-my-zsh/custom/plugins/zsh-vi-mode

$(HOME)/.p10k.zsh:
	cp .p10k.zsh $(HOME)/
	cp $(HOME)/.zshrc $(HOME)/.zshrc.dotfiles_backup
	cp .zshrc $(HOME)/

.PHONY: install tmux zsh

install: zsh tmux \
	$(HOME)/.config \
	$(HOME)/.config/bspwm $(HOME)/.config/sxhkd $(HOME)/.config/rofi $(HOME)/.config/polybar

tmux:
	$(HOME)/.tmux.conf

zsh: $(HOME)/.oh-my-zsh \
	$(HOME)/.env.example \
	$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
	$(HOME)/.oh-my-zsh/custom/plugins/zsh-vi-mode \
	$(HOME)/.p10k.zsh
