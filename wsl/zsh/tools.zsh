# Mise - polyglot tool manager (handles node, rust, go, and CLI tools)
eval "$(mise activate zsh)"

# Enable Oh My Posh hot reload for theme switching
oh-my-posh enable reload 2>/dev/null || true
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"

# Zoxide is now managed by mise, but still needs shell init
eval "$(zoxide init --cmd z zsh)"
