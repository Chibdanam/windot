#!/bin/bash
# Install AI tools: claude-code, opencode
# Note: claude-code is installed via official curl script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

# Ensure mise is activated for this session
# (node is installed via mise in 00-prerequisites.sh)
eval "$(mise activate bash)" 2>/dev/null || {
    echo "Warning: mise not found. Run 00-prerequisites.sh first."
    exit 1
}

echo "Installing AI tools..."

# claude-code
if is_installed claude; then
    echo -e "${YELLOW}[SKIP]${NC} claude-code already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} claude-code"
    curl -fsSL https://claude.ai/install.sh | bash
fi

# opencode
if is_installed opencode; then
    echo -e "${YELLOW}[SKIP]${NC} opencode already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} opencode"
    curl -fsSL https://opencode.ai/install | bash
fi

echo "AI tools installation complete!"
