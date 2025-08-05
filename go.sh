#!/bin/bash
set -e

# XDG directories
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
GO_INSTALL_DIR="$XDG_DATA_HOME/go"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Remove existing Go installations
remove_existing_go() {
    log "Removing existing Go installations..."
    
    # Common system locations
    for path in /usr/local/go /opt/go /usr/lib/go /usr/share/go; do
        if [[ -d "$path" ]]; then
            warn "Found system Go at $path (requires sudo to remove)"
            sudo rm -rf "$path" 2>/dev/null || true
        fi
    done
    
    # XDG location
    [[ -d "$GO_INSTALL_DIR" ]] && rm -rf "$GO_INSTALL_DIR"
    
    # Package manager installations
    if command -v apt &>/dev/null && dpkg -l | grep -q golang; then
        warn "Removing apt-installed Go packages"
        sudo apt remove -y golang-go golang-1.* 2>/dev/null || true
    fi
    
    if command -v brew &>/dev/null && brew list | grep -q "^go$"; then
        warn "Removing Homebrew Go"
        brew uninstall go 2>/dev/null || true
    fi
}

# Get latest version and install
install_latest_go() {
    log "Fetching latest Go version..."
    GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
    
    # Platform detection
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
    esac
    
    log "Installing $GO_VERSION ($OS-$ARCH) to $GO_INSTALL_DIR"
    
    # Download and extract
    PACKAGE="$GO_VERSION.$OS-$ARCH.tar.gz"
    mkdir -p "$XDG_DATA_HOME"
    curl -fsSL "https://go.dev/dl/$PACKAGE" | tar -xz -C "$XDG_DATA_HOME"
}

# Setup environment
setup_environment() {
    mkdir -p "$XDG_BIN_HOME" "$XDG_DATA_HOME/go-workspace/bin"
    
    # Update shell profiles
    for profile in ~/.bashrc ~/.zshrc ~/.profile; do
        [[ -f "$profile" ]] || continue
        
        # Remove old Go entries
        sed -i.bak '/# Go environment/,/^$/d' "$profile" 2>/dev/null || true
        
        # Add new configuration
        cat >> "$profile" << EOF

# Go environment (XDG compliant)
export GOROOT=$GO_INSTALL_DIR
export GOPATH=\$XDG_DATA_HOME/go-workspace
export PATH=\$GOROOT/bin:\$XDG_BIN_HOME:\$PATH
EOF
        log "Updated $profile"
    done
}

# Main execution
main() {
    remove_existing_go
    install_latest_go
    setup_environment
    
    log "$GO_VERSION installed successfully"
    log "Run: source ~/.bashrc && go version"
}

main
