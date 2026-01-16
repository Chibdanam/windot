#!/bin/bash
# Install dev core: cmake, build-essential, python, docker, mingw-w64, libx11-dev
# Note: neovim is now installed via mise in 00-prerequisites.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing dev core tools..."

# cmake
if is_installed cmake; then
    echo -e "${YELLOW}[SKIP]${NC} cmake already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} cmake"
    sudo apt update
    sudo apt install -y cmake
fi

# build-essential (g++, gcc, make)
if is_installed g++; then
    echo -e "${YELLOW}[SKIP]${NC} build-essential already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} build-essential"
    sudo apt install -y build-essential
fi

# python3 and pip
if is_installed python3; then
    echo -e "${YELLOW}[SKIP]${NC} python3 already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} python3"
    sudo apt install -y python3 python3-pip python3-venv
fi

# docker
if is_installed docker; then
    echo -e "${YELLOW}[SKIP]${NC} docker already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} docker"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    echo "Note: Log out and back in for docker group to take effect"
fi

# mingw-w64 (cross-compilation for Windows)
if is_installed x86_64-w64-mingw32-gcc; then
    echo -e "${YELLOW}[SKIP]${NC} mingw-w64 already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} mingw-w64"
    sudo apt install -y mingw-w64
fi

# libx11-dev (X11 development libraries)
if dpkg -s libx11-dev &> /dev/null; then
    echo -e "${YELLOW}[SKIP]${NC} libx11-dev already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} libx11-dev"
    sudo apt install -y libx11-dev
fi

echo "Dev core tools installation complete!"
