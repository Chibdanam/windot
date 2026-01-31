#!/bin/bash
# Install shell tools: git, zsh
# Note: git-delta, starship are installed via mise in 00-prerequisites.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing shell tools..."

# git
if is_installed git; then
    echo -e "${YELLOW}[SKIP]${NC} git already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} git"
    sudo apt update
    sudo apt install -y git
fi

# zsh
if is_installed zsh; then
    echo -e "${YELLOW}[SKIP]${NC} zsh already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} zsh"
    sudo apt update
    sudo apt install -y zsh
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${GREEN}[SET]${NC} zsh as default shell"
    sudo chsh -s "$(which zsh)" "$USER"
else
    echo -e "${YELLOW}[SKIP]${NC} zsh already default shell"
fi

echo "Shell tools installation complete!"
