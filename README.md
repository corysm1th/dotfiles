# dotfiles

## What's Configured Here

### Alacritty

* OneDark Theme
* JetBrains Mono with Nerd Font Glyphs

### zsh

* powerline-go prompt decorations
* jeffreytse/zsh-vi-mode
* fzf fuzzy finder (command history, files)

### tmux

* Prefix Key: Ctrl-Space
* Prefix, Enter: Binary space partitioned panes
* Prefix, {j,k,h,l}: Vim style pane focus
* TPM Plugins

### Language Environments

* Go
* Rust
* Python3 w/ pyenv and virtualenv

## Project Structure

TODO

## Ideas

* jump codes: aa ab ac (emacs: ovi, vim: leap)
* fzf symbol picker: func1, func2
* fzf marker picker
* fzf buffer picker
* diagnostic picker: jump to errors / linter issues
* bash lsp for zsh with fzf powered code completions

## vscode extensions

vs code extensions are listed at `vscode-extensions.txt`

The can be restored by running `cat vscode-extensions.txt | xargs -L 1 code --install-extension`

