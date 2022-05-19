# dotfiles

## What's Configured Here

### Alacritty

* Dracula Theme
* JetBrains Mono with Nerd Font Glyphs

### zsh

* powerlevel10k prompt
* GOROOT/GOPATH

#### zsh plugins

        git
        zsh-vi-mode
        zsh-syntax-highlighting

## Prerequisites

* Install zsh (package manager)
* Install JetBrains Mono patched with Nerd Font

## Project Structure

The `main` branch assumes a Linux OS.

Also included are `windows-wsl` and `macos` branches for the respective config file variants.

This repo should be cloned to the `${HOME}` directory.

```sh
# from ${HOME} working directory
git clone https://github.com/corysm1th/dotfiles.git
# results in ${HOME}/dotfiles
```

From here, change to the `dotfiles` directory and run `make install`.

The `Makefile` will copy `oh-my-zsh` and `.zshrc` to the home folder.

## vscode extensions

vs code extensions are listed at `vscode-extensions.txt`

The can be restored by running `cat vscode-extensions.txt | xargs -L 1 code --install-extension`
