# Developer VM Instance Startup Script

A comprehensive startup script for setting up a GCP VM development environment optimized for Go and AI development on Ubuntu 24.04 LTS.

## Quick Start

```bash
# Download and run the startup script
curl -fsSL https://raw.githubusercontent.com/dnjmn/gcp_scripts/main/dev-vm-startup.sh | sudo bash

# Or clone the repository and run locally
git clone https://github.com/dnjmn/gcp_scripts.git
cd gcp_scripts
sudo ./dev-vm-startup.sh

# Verify the installation
./verify-installation.sh
```

## What Gets Installed

### Core Development Environment
- **System Updates**: Latest Ubuntu 24.04 LTS packages
- **Build Tools**: GCC, make, and essential development packages
- **Shell**: Zsh with Oh My Zsh framework
- **Terminal**: tmux for session management

### Programming Languages (Priority)
- **Go** (latest version) - Complete development environment
  - gopls (language server)
  - delve debugger
  - staticcheck linter
  - goimports formatter
- **Python 3** - AI/ML development stack
  - numpy, pandas, matplotlib
  - scikit-learn, jupyter, ipython
- **Node.js** (LTS) - Web development support

### Code Editor (Priority)
- **Neovim** (latest) with vim-plug plugin manager
- Pre-configured for Go and Python development
- Essential plugins for modern development workflow

### Enhanced CLI Tools
- `ripgrep` (rg) - Fast text search
- `fd-find` (fd) - Fast file finder  
- `bat` - Enhanced cat with syntax highlighting
- `exa` - Enhanced ls with colors
- `httpie` - User-friendly HTTP client

## Features

### ✅ Idempotent Design
- Safe to run multiple times
- Checks existing installations
- Updates to latest versions when needed

### ✅ XDG Base Directory Compliance
- Follows XDG specification for configuration
- Clean directory structure in `~/.config`, `~/.local`, etc.

### ✅ Comprehensive Logging
- Detailed logs in `/var/log/dev-vm-startup.log`
- Progress tracking and error handling
- Easy troubleshooting

### ✅ User-Centric Setup
- Creates and configures user `dnjmn`
- Proper permissions and ownership
- Sudo access for development needs

## Directory Structure

After installation, the user directory will have:

```
/home/dnjmn/
├── .config/          # XDG config directory
│   └── nvim/         # Neovim configuration
├── .local/
│   ├── bin/          # User binaries (Python packages)
│   ├── share/        # XDG data directory
│   └── state/        # XDG state directory
├── .cache/           # XDG cache directory
├── .oh-my-zsh/       # Oh My Zsh installation
├── .zshrc           # Zsh configuration
└── go/               # Go workspace
    └── bin/          # Go development tools
```

## Configuration Files

### Neovim (`~/.config/nvim/init.vim`)
- Basic configuration for Go and Python
- Plugin management with vim-plug
- LSP support with nvim-lspconfig
- File tree with NERDTree
- Git integration with vim-fugitive

### Zsh (`~/.zshrc`)
- Oh My Zsh framework
- Go environment variables
- Python path configuration
- XDG directory exports
- Development-friendly aliases

## Environment Variables

The script configures these key environment variables:

```bash
# Go Development
export GOPATH=/home/dnjmn/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin:$GOBIN

# Python Development  
export PATH="$HOME/.local/bin:$PATH"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Editor
export EDITOR=nvim
export VISUAL=nvim
```

## Verification

Use the included verification script to check your installation:

```bash
./verify-installation.sh
```

This will check:
- ✅ User creation and configuration
- ✅ XDG directory structure
- ✅ System package installation
- ✅ Go installation and tools
- ✅ Neovim configuration
- ✅ Python environment
- ✅ Shell configuration
- ✅ Enhanced CLI tools

## Troubleshooting

### Check the log file
```bash
sudo tail -f /var/log/dev-vm-startup.log
```

### Re-run specific sections
The script is idempotent, so you can safely re-run it to fix any issues.

### Manual verification
```bash
# Check Go installation
go version
go env GOPATH

# Check Python packages
python3 -c "import numpy, pandas, matplotlib; print('Python packages OK')"

# Check Neovim
nvim --version

# Check shell
echo $SHELL
```

## Customization

The script is designed to be extensible. You can:

1. **Modify user settings**: Change `TARGET_USER` variable
2. **Add packages**: Extend the package lists in respective functions
3. **Custom configurations**: Add your dotfiles after the script runs
4. **Additional tools**: Extend the installation functions

## Requirements

- Ubuntu 24.04 LTS (minimal installation)
- Root or sudo access
- Internet connection for package downloads
- At least 2GB free disk space

## Future Enhancements

This script provides a solid foundation that can be extended with:
- Container tools (Docker, Kubernetes)
- Additional AI/ML frameworks (TensorFlow, PyTorch)
- Cloud tools (GCP SDK, Terraform)
- Database systems
- Security tools
- IDE configurations

## Contributing

This script is part of the `dnjmn/gcp_scripts` repository. Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share your customizations

## License

See the [LICENSE](LICENSE) file in the repository root.