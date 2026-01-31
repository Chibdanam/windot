#!/bin/bash
# Install utilities via apt: unzip, fastfetch
# Note: bat, eza, fzf, ripgrep, fd, zoxide, bottom, sd, tldr are now installed via mise in 00-prerequisites.sh
# Note: tree is replaced by eza --tree

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing utilities..."

# unzip
if is_installed unzip; then
    echo -e "${YELLOW}[SKIP]${NC} unzip already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} unzip"
    sudo apt update
    sudo apt install -y unzip
fi

# fastfetch
if is_installed fastfetch; then
    echo -e "${YELLOW}[SKIP]${NC} fastfetch already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} fastfetch"
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null || true
    sudo apt update
    sudo apt install -y fastfetch
fi

echo "Utilities installation complete!"
