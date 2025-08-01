#!/bin/bash

# Developer VM Instance Startup Script for GCP
# Ubuntu 24.04 LTS minimal - Go and AI development environment
# User: dnjmn
# 
# This script sets up a complete development environment with:
# - System updates and essential packages
# - Go development environment
# - Neovim (latest)
# - Python for AI development
# - Development tools and utilities

set -euo pipefail

# Configuration
TARGET_USER="dnjmn"
LOG_FILE="/var/log/dev-vm-startup.log"
SCRIPT_VERSION="1.0.0"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="/home/${TARGET_USER}/.config"
export XDG_DATA_HOME="/home/${TARGET_USER}/.local/share"
export XDG_CACHE_HOME="/home/${TARGET_USER}/.cache"
export XDG_STATE_HOME="/home/${TARGET_USER}/.local/state"

# Logging function
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_error() { log "ERROR" "$@"; }
log_warn() { log "WARN" "$@"; }

# Error handling
handle_error() {
    log_error "Script failed at line $1. Exit code: $2"
    exit "$2"
}

trap 'handle_error $LINENO $?' ERR

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Create user if doesn't exist
ensure_user() {
    if ! id "$TARGET_USER" &>/dev/null; then
        log_info "Ensuring zsh is installed before creating user"
        if ! command -v zsh &>/dev/null; then
            log_info "Installing zsh"
            apt-get update
            apt-get install -y zsh
        fi
        log_info "Creating user: $TARGET_USER with default shell /bin/zsh"
        useradd -m -s /bin/zsh "$TARGET_USER"
        usermod -aG sudo "$TARGET_USER"
        log_info "User $TARGET_USER created and added to sudo group"
    else
        log_info "User $TARGET_USER already exists"
    fi
}

# Create XDG directories
setup_xdg_directories() {
    log_info "Setting up XDG Base Directory structure"
    
    local dirs=(
        "$XDG_CONFIG_HOME"
        "$XDG_DATA_HOME"
        "$XDG_CACHE_HOME"
        "$XDG_STATE_HOME"
        "/home/${TARGET_USER}/.local/bin"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            chown "$TARGET_USER:$TARGET_USER" "$dir"
            log_info "Created directory: $dir"
        fi
    done
}

# System updates and base packages
update_system() {
    log_info "Updating system packages"
    apt-get update -y
    apt-get upgrade -y
    
    log_info "Installing essential packages"
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        wget \
        gnupg \
        lsb-release \
        software-properties-common \
        build-essential \
        git \
        vim \
        tmux \
        htop \
        tree \
        unzip \
        zip \
        jq \
        sqlite3 \
        pkg-config \
        libssl-dev \
        zsh
    
    log_info "System update completed"
}

# Install Go (latest version)
install_go() {
    log_info "Installing Go programming language"
    
    # Get latest Go version
    local go_version
    go_version=$(curl -s https://go.dev/VERSION?m=text | head -n1)
    local go_tarball="${go_version}.linux-amd64.tar.gz"
    local go_url="https://go.dev/dl/${go_tarball}"
    
    # Check if Go is already installed and up to date
    if command -v go &>/dev/null; then
        local current_version
        current_version=$(go version | cut -d' ' -f3)
        if [[ "$current_version" == "$go_version" ]]; then
            log_info "Go $go_version is already installed"
            return 0
        else
            log_info "Updating Go from $current_version to $go_version"
            rm -rf /usr/local/go
        fi
    fi
    
    log_info "Downloading Go $go_version"
    cd /tmp
    wget -q "$go_url"
    
    log_info "Installing Go $go_version"
    tar -C /usr/local -xzf "$go_tarball"
    rm "$go_tarball"
    
    # Add Go to PATH for all users
    cat > /etc/profile.d/go.sh << 'EOF'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/home/dnjmn/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
EOF
    
    chmod +x /etc/profile.d/go.sh
    
    # Source for current session
    source /etc/profile.d/go.sh
    
    log_info "Go installation completed: $(go version)"
}

# Install Go development tools
install_go_tools() {
    log_info "Installing Go development tools"
    
    # Ensure GOPATH exists
    sudo -u "$TARGET_USER" mkdir -p "/home/${TARGET_USER}/go/bin"
    
    # Install Go tools as the target user
    sudo -u "$TARGET_USER" bash -c 'source /etc/profile.d/go.sh && {
        go install golang.org/x/tools/gopls@latest
        go install github.com/go-delve/delve/cmd/dlv@latest
        go install honnef.co/go/tools/cmd/staticcheck@latest
        go install golang.org/x/tools/cmd/goimports@latest
    }'
    
    log_info "Go development tools installed"
}

# Install Neovim (latest version)
install_neovim() {
    log_info "Installing Neovim (latest version)"
    
    # Add Neovim PPA for latest version
    add-apt-repository -y ppa:neovim-ppa/unstable
    apt-get update -y
    apt-get install -y neovim
    
    # Install vim-plug for Neovim
    sudo -u "$TARGET_USER" bash -c 'export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"; curl -fLo "$XDG_DATA_HOME/nvim/site/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    
    # Create basic Neovim configuration
    local nvim_config_dir="$XDG_CONFIG_HOME/nvim"
    mkdir -p "$nvim_config_dir"
    
    cat > "$nvim_config_dir/init.vim" << 'EOF'
" Basic Neovim configuration for Go and Python development
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set hlsearch
set incsearch
set ignorecase
set smartcase
set mouse=a
set clipboard=unnamedplus

" Go-specific settings
autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab

" Plugin management with vim-plug
call plug#begin()
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'tpope/vim-fugitive'
call plug#end()

" Basic key mappings
let mapleader = " "
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
EOF
    
    chown -R "$TARGET_USER:$TARGET_USER" "$nvim_config_dir"
    
    log_info "Neovim installation completed"
}

# Install Python environment for AI development
install_python_env() {
    log_info "Setting up Python environment for AI development"
    
    # Install Python and pip
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        python-is-python3
    
    # Install essential Python packages for AI development
    sudo -u "$TARGET_USER" python3 -m pip install --user --upgrade \
        pip \
        setuptools \
        wheel \
        virtualenv \
        numpy \
        pandas \
        matplotlib \
        scikit-learn \
        jupyter \
        ipython
    
    # Add user local bin to PATH
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "/home/${TARGET_USER}/.bashrc"
    
    log_info "Python environment setup completed"
}

# Configure Git for the user
configure_git() {
    log_info "Configuring Git for user $TARGET_USER"
    
    sudo -u "$TARGET_USER" bash -c 'cat >> ~/.bashrc << EOF

# Git configuration
export EDITOR=nvim
EOF'
    
    log_info "Git configuration completed"
}

# Install additional development tools
install_dev_tools() {
    log_info "Installing additional development tools"
    
    # Install Node.js and npm from official Ubuntu repository
    apt-get install -y nodejs npm
    
    # Install useful CLI tools
    apt-get install -y \
        httpie \
        ripgrep \
        fd-find \
        bat \
        exa
    
    log_info "Additional development tools installed"
}

# Set up shell environment
setup_shell() {
    log_info "Setting up shell environment for $TARGET_USER"
    
    # Install Oh My Zsh for the user safely using git clone
    if [[ ! -d "/home/${TARGET_USER}/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh via git clone"
        sudo -u "$TARGET_USER" git clone https://github.com/ohmyzsh/ohmyzsh.git "/home/${TARGET_USER}/.oh-my-zsh"
        
        # Copy the zshrc template
        sudo -u "$TARGET_USER" cp "/home/${TARGET_USER}/.oh-my-zsh/templates/zshrc.zsh-template" "/home/${TARGET_USER}/.zshrc"
        log_info "Oh My Zsh installed successfully"
    else
        log_info "Oh My Zsh already installed"
    fi
    
    # Set zsh as default shell for the user
    chsh -s /bin/zsh "$TARGET_USER"
    
    # Configure zsh with development-friendly settings
    sudo -u "$TARGET_USER" bash -c 'cat >> ~/.zshrc << EOF

# Development environment variables
export EDITOR=nvim
export VISUAL=nvim

# Go environment
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin:$GOBIN

# Python environment
export PATH="$HOME/.local/bin:$PATH"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Useful aliases
alias ll="exa -la"
alias ls="exa"
alias cat="bat"
alias find="fd"
alias grep="rg"
alias vim="nvim"
alias vi="nvim"

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"
EOF'
    
    log_info "Shell environment setup completed"
}

# Main execution
main() {
    log_info "Starting Developer VM setup script v$SCRIPT_VERSION"
    log_info "Target user: $TARGET_USER"
    
    check_root
    ensure_user
    setup_xdg_directories
    update_system
    install_go
    install_go_tools
    install_neovim
    install_python_env
    configure_git
    install_dev_tools
    setup_shell
    
    log_info "Developer VM setup completed successfully!"
    log_info "Please run 'source ~/.zshrc' or log out and back in to apply all changes"
    log_info "Log file: $LOG_FILE"
}

# Run main function
main "$@"