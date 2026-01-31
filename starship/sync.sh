#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.config
cp "$SCRIPT_DIR/starship.toml" ~/.config/starship.toml
echo "Synced starship config to ~/.config/starship.toml"
