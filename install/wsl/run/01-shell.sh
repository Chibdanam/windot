#!/bin/bash
# Install shell tools: zsh, oh-my-posh
# Note: git-delta is now installed via mise in 00-prerequisites.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing shell tools..."

# zsh
if is_installed zsh; then
    echo -e "${YELLOW}[SKIP]${NC} zsh already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} zsh"
    sudo apt update
    sudo apt install -y zsh
fi

# oh-my-posh
if is_installed oh-my-posh; then
    echo -e "${YELLOW}[SKIP]${NC} oh-my-posh already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} oh-my-posh"
    curl -s https://ohmyposh.dev/install.sh | bash -s
fi

echo "Shell tools installation complete!"
