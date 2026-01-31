# windot

Linux server dotfiles — automated setup and configuration for Ubuntu Server environments.

## Tech Stack

- **Neovim** — editor with LSP, Treesitter, Telescope, Copilot
- **Zsh** — shell with Zinit, syntax highlighting, fzf-tab, fuzzy navigation
- **Mise** — polyglot tool manager (Node, Go, Rust, CLI utilities)
- **Starship** — cross-shell prompt
- **Git** — delta pager, nvimdiff merge tool

## Directory Structure

```
windot/
├── sync.sh                      # Root sync orchestrator
├── install/                     # Automated installation
│   ├── install.sh
│   └── run/
│       ├── 00-prerequisites.sh
│       ├── 01-shell.sh
│       ├── 02-utilities.sh
│       ├── 03-dev-core.sh
│       ├── 05-databases.sh
│       └── 06-ai.sh
├── git/                         # Git configuration
│   ├── .gitconfig
│   └── sync.sh
├── mise/                        # Tool manager
│   ├── config.toml
│   └── sync.sh
├── starship/                    # Prompt theme
│   ├── starship.toml
│   └── sync.sh
├── neovim/                      # Editor configuration
│   ├── sync.sh
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── options.lua
│       ├── plugins.lua
│       └── plugins/
│           ├── lsp-config.lua
│           ├── telescope.lua
│           ├── treesitter.lua
│           ├── neotree.lua
│           ├── copilot.lua
│           └── colorscheme.lua
└── zsh/                         # Shell configuration
    ├── sync.sh
    ├── .zshrc
    ├── aliases.zsh
    ├── completions.zsh
    ├── functions.zsh
    ├── fuzzy-dir.zsh
    ├── history.zsh
    └── tools.zsh
```

## Installation

```bash
git clone <repo-url> ~/windot
cd ~/windot
./install/install.sh
```

The installer presents a menu to run all or individual install scripts. Scripts install mise and all tools defined in `mise/config.toml`.

## Syncing Configurations

```bash
./sync.sh
```

Select "all" to sync everything, or pick individual modules (git, mise, starship, neovim, zsh). Each module has its own `sync.sh` that copies or symlinks config files to their expected locations.
