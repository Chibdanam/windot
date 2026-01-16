#!/bin/bash
# Install misc tools: ansible, xleak, lazysql
# Note: xleak uses cargo, lazysql uses go (both from mise)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

# Ensure mise is activated for this session (for cargo)
eval "$(mise activate bash)" 2>/dev/null || {
    echo "Warning: mise not found. Run 00-prerequisites.sh first."
    exit 1
}

echo "Installing misc tools..."

# ansible
if is_installed ansible; then
    echo -e "${YELLOW}[SKIP]${NC} ansible already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} ansible"
    sudo apt update
    sudo apt install -y ansible
fi

# xleak (via cargo from mise)
if is_installed xleak; then
    echo -e "${YELLOW}[SKIP]${NC} xleak already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} xleak"
    cargo install xleak
fi

# lazysql (via go from mise - not available in mise registry)
if is_installed lazysql; then
    echo -e "${YELLOW}[SKIP]${NC} lazysql already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} lazysql"
    go install github.com/jorgerojas26/lazysql@latest
fi

echo "Misc tools installation complete!"
