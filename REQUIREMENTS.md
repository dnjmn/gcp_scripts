# Developer VM Requirements Document

## Overview
This document outlines the software and tools installed by the `dev-vm-startup.sh` script for the GCP VM development environment.

## Base System
- **OS**: Ubuntu 24.04 LTS minimal
- **Target User**: dnjmn
- **Architecture**: linux-amd64

## System Configuration

### XDG Base Directory Specification
The environment follows XDG Base Directory specification:
- `XDG_CONFIG_HOME`: `~/.config`
- `XDG_DATA_HOME`: `~/.local/share`
- `XDG_CACHE_HOME`: `~/.cache`
- `XDG_STATE_HOME`: `~/.local/state`

### System Updates and Base Packages
- System package updates (apt-get update && upgrade)
- Essential build tools and utilities:
  - `build-essential` - Compiler and build tools
  - `git` - Version control system
  - `curl`, `wget` - Download utilities
  - `vim`, `tmux` - Terminal utilities
  - `htop`, `tree` - System monitoring and file utilities
  - `unzip`, `zip` - Archive tools
  - `jq` - JSON processor
  - `sqlite3` - Database tools
  - `zsh` - Enhanced shell

## Programming Languages and Runtimes

### Go Development Environment ⭐ (Priority)
- **Go Version**: Latest stable (automatically fetched from go.dev)
- **Installation Path**: `/usr/local/go`
- **Environment Variables**:
  - `GOPATH`: `/home/dnjmn/go`
  - `GOBIN`: `$GOPATH/bin`
  - `PATH` includes Go binaries

#### Go Development Tools
- `gopls` - Go language server for LSP support
- `delve` (`dlv`) - Go debugger
- `staticcheck` - Static analysis tool
- `goimports` - Import management tool

### Python Environment
- **Python Version**: Python 3 (system default for Ubuntu 24.04)
- **Package Manager**: pip
- **Virtual Environment**: venv support
- **AI/ML Libraries**:
  - `numpy` - Numerical computing
  - `pandas` - Data manipulation
  - `matplotlib` - Data visualization
  - `scikit-learn` - Machine learning
  - `jupyter` - Interactive notebooks
  - `ipython` - Enhanced Python shell

### Node.js
- **Version**: LTS (via NodeSource repository)
- **Package Manager**: npm

## Code Editors and IDEs

### Neovim ⭐ (Priority)
- **Version**: Latest unstable (via PPA)
- **Plugin Manager**: vim-plug
- **Configuration**: Basic setup in `~/.config/nvim/init.vim`
- **Plugins**:
  - `vim-go` - Go language support
  - `nvim-lspconfig` - LSP client configuration
  - `nvim-treesitter` - Syntax highlighting
  - `nerdtree` - File explorer
  - `vim-airline` - Status line
  - `vim-fugitive` - Git integration

## Development Tools and Utilities

### Terminal and Shell
- **Default Shell**: zsh with Oh My Zsh
- **Terminal Multiplexer**: tmux
- **Enhanced CLI Tools**:
  - `ripgrep` (`rg`) - Fast text search
  - `fd-find` - Fast file finder
  - `bat` - Enhanced cat with syntax highlighting
  - `exa` - Enhanced ls
  - `httpie` - HTTP client

### Version Control
- **Git**: Latest version from Ubuntu repositories
- **Configuration**: Basic setup with nvim as default editor

## User Environment

### Shell Configuration (zsh)
- Oh My Zsh framework
- Custom aliases for development workflow
- Environment variables for Go, Python, and XDG
- Enhanced command line experience

### Directory Structure
```
/home/dnjmn/
├── .config/          # XDG config directory
│   └── nvim/         # Neovim configuration
├── .local/
│   ├── bin/          # User binaries
│   ├── share/        # XDG data directory
│   └── state/        # XDG state directory
├── .cache/           # XDG cache directory
└── go/               # Go workspace
    └── bin/          # Go binaries
```

## Script Features

### Error Handling and Logging
- Comprehensive error handling with `set -euo pipefail`
- Detailed logging to `/var/log/dev-vm-startup.log`
- Progress tracking and status updates

### Idempotency
- Safe to run multiple times
- Checks for existing installations before proceeding
- Updates existing software when newer versions are available

### Security Considerations
- Creates user with sudo privileges
- Uses official package repositories and sources
- Follows security best practices for downloads

## Installation Verification

Use the provided `verify-installation.sh` script to validate all components are correctly installed and configured.

## Future Extensions

The script is designed to be extensible. Future versions may include:
- Container tools (Docker, Kubernetes)
- Additional AI/ML frameworks (TensorFlow, PyTorch)
- Cloud tools (GCP SDK, Terraform)
- Additional IDEs and editors
- Database systems and clients
- Security tools and configurations

## Usage

```bash
# Run as root or with sudo
sudo ./dev-vm-startup.sh

# Check installation
./verify-installation.sh
```

## Maintenance

- The script automatically installs the latest versions of Go and Neovim
- Python packages are installed with `--user` flag for user-specific installation
- System packages use Ubuntu's package management for automatic security updates
- Log file location: `/var/log/dev-vm-startup.log`