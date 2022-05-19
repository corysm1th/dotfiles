$(HOME)/.oh-my-zsh:
	cp -r .oh-my-zsh $(HOME)/

$(HOME)/.zshrc:
	cp $(HOME)/.zshrc $(HOME)/.zshrc.dotfiles_backup
	cp .zshrc $(HOME)/

.PHONY: install

install: $(HOME)/.oh-my-zsh $(HOME)/.zshrc
