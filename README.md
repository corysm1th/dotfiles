# dotfiles

## What's Configured Here

### Development Environments

* Python3
* Go
* Rust

### Alacritty

* KDE Breeze Theme
* JetBrains Mono with Nerd Font Glyphs

### zsh

* powerline-go prompt decorations
* GOROOT/GOPATH

#### zsh plugins

        aws
        dotenv
        gcloud
        git
        helm
        kubectl
        tmux
        zsh-vi-mode
        zsh-syntax-highlighting

### tmux

* Prefix Key: Ctrl-Space
* Prefix, Enter: Binary space partitioned panes
* Prefix, {j,k,h,l}: Vim style pane focus
* TPM Plugins

                nord-tmux

## Project Structure

The `main` branch assumes KDE Neon. Friendship ended with bspwm. KDE Neon is my best freind now.

Also included are `windows-wsl` and `macos` branches for the respective config file variants.

### .env and local settings

`zsh` is configured with a `dotenv` plugin which will automatically source any `.env` files it finds when you `cd` into a directory. So you can keep your personal stuff (SSH keys, API tokens) in the `.env` file in your home directory, and keep your other dotfiles managed in version control.

## vscode extensions

vs code extensions are listed at `vscode-extensions.txt`

The can be restored by running `cat vscode-extensions.txt | xargs -L 1 code --install-extension`

