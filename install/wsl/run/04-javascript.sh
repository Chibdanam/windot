#!/bin/bash
# Install JavaScript tools: eas-cli
# Note: node, pnpm, bun are now installed via mise in 00-prerequisites.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

# Ensure mise is activated for this session
eval "$(mise activate bash)" 2>/dev/null || {
    echo "Warning: mise not found. Run 00-prerequisites.sh first."
    exit 1
}

echo "Installing JavaScript tools..."

# eas-cli
if is_installed eas; then
    echo -e "${YELLOW}[SKIP]${NC} eas-cli already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} eas-cli"
    npm install -g eas-cli
fi

echo "JavaScript tools installation complete!"
