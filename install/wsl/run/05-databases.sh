#!/bin/bash
# Install database tools: lazysql
# Note: lazysql uses go (installed via mise)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

# Ensure mise is activated for this session (for go)
eval "$(mise activate bash)" 2>/dev/null || {
    echo "Warning: mise not found. Run 00-prerequisites.sh first."
    exit 1
}

echo "Installing database tools..."

# lazysql (via go from mise - not available in mise registry)
if is_installed lazysql; then
    echo -e "${YELLOW}[SKIP]${NC} lazysql already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} lazysql"
    go install github.com/jorgerojas26/lazysql@latest
fi

echo "Database tools installation complete!"
