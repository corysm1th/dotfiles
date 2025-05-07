#!/bin/bash

# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

/opt/homebrew/bin/brew install \
  coreutils \
  bat \
  neofetch \
  nvim \
  ripgrep

chsh -s $(which zsh)

mkdir -p ${HOME}/.local/bin || true

ln -s $(which fdfind) ~/.local/bin/fd
ln -s $(which batcat) ~/.local/bin/bat

echo "Shell bootstrap complete. Reboot to apply."
