# dotfiles

## What's Configured Here

### Alacritty

* Dracula Theme
* JetBrains Mono with Nerd Font Glyphs

### zsh

* powerlevel10k prompt
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

## Prerequisites

* Install JetBrains Mono patched with Nerd Font (included)

```sh
sudo apt install git curl zsh tmux vim bspwm sxhkd polybar rofi
```

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

### .env and local settings

`zsh` is configured with a `dotenv` plugin which will automatically source any `.env` files it finds when you `cd` into a directory. So you can keep your personal stuff (SSH keys, API tokens) in the `.env` file in your home directory, and keep your other dotfiles managed in version control.

## vscode extensions

vs code extensions are listed at `vscode-extensions.txt`

The can be restored by running `cat vscode-extensions.txt | xargs -L 1 code --install-extension`

## Secure Screen Locker

https://github.com/google/xsecurelock
https://packages.ubuntu.com/search?keywords=xsecurelock

## Ubuntu Setup

```sh
sudo apt install -y bspwm cmake curl feh firefox git gparted htop libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev lxappearance pkg-config pnupg2 podman polybar python3 rofi sxhkd tmux wget zsh
```

* Xubuntu with XFCE / LighDM

* Supports Secure Boot

* Supports Disk Encryption

  * ZFS partitions cannot be shrunk




