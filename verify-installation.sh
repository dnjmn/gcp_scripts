#!/bin/bash

# Verification Script for Developer VM Setup
# This script validates that all components were installed correctly

set -euo pipefail

TARGET_USER="dnjmn"
VERIFICATION_LOG="/tmp/verification-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}" | tee -a "$VERIFICATION_LOG"
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$VERIFICATION_LOG"
}

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$VERIFICATION_LOG"
}

log_error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$VERIFICATION_LOG"
}

log_info() {
    echo -e "${BLUE}ℹ $1${NC}" | tee -a "$VERIFICATION_LOG"
}

# Check functions
check_user() {
    log_header "User Configuration"
    
    if id "$TARGET_USER" &>/dev/null; then
        log_success "User $TARGET_USER exists"
        
        # Check if user is in sudo group
        if groups "$TARGET_USER" | grep -q sudo; then
            log_success "User $TARGET_USER is in sudo group"
        else
            log_warning "User $TARGET_USER is not in sudo group"
        fi
        
        # Check default shell
        local user_shell
        user_shell=$(getent passwd "$TARGET_USER" | cut -d: -f7)
        if [[ "$user_shell" == "/bin/zsh" ]]; then
            log_success "Default shell is zsh"
        else
            log_warning "Default shell is $user_shell (expected: /bin/zsh)"
        fi
    else
        log_error "User $TARGET_USER does not exist"
    fi
}

check_xdg_directories() {
    log_header "XDG Base Directory Structure"
    
    local xdg_dirs=(
        "/home/${TARGET_USER}/.config"
        "/home/${TARGET_USER}/.local/share"
        "/home/${TARGET_USER}/.cache"
        "/home/${TARGET_USER}/.local/state"
        "/home/${TARGET_USER}/.local/bin"
    )
    
    for dir in "${xdg_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "Directory exists: $dir"
        else
            log_error "Directory missing: $dir"
        fi
    done
}

check_system_packages() {
    log_header "System Packages"
    
    local packages=(
        "build-essential"
        "git"
        "curl"
        "wget"
        "vim"
        "tmux"
        "htop"
        "tree"
        "unzip"
        "zip"
        "jq"
        "sqlite3"
        "zsh"
        "nodejs"
        "python3"
        "python3-pip"
        "neovim"
    )
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            log_success "Package installed: $package"
        else
            log_error "Package missing: $package"
        fi
    done
}

check_go_installation() {
    log_header "Go Programming Language"
    
    if command -v go &>/dev/null; then
        local go_version
        go_version=$(go version)
        log_success "Go installed: $go_version"
        
        # Check GOPATH
        if sudo -u "$TARGET_USER" bash -c 'source /etc/profile.d/go.sh && [[ -n "$GOPATH" ]]'; then
            local gopath
            gopath=$(sudo -u "$TARGET_USER" bash -c 'source /etc/profile.d/go.sh && echo $GOPATH')
            log_success "GOPATH configured: $gopath"
            
            if [[ -d "$gopath" ]]; then
                log_success "GOPATH directory exists"
            else
                log_error "GOPATH directory does not exist"
            fi
        else
            log_error "GOPATH not configured"
        fi
    else
        log_error "Go is not installed or not in PATH"
    fi
}

check_go_tools() {
    log_header "Go Development Tools"
    
    local go_tools=(
        "gopls"
        "dlv"
        "staticcheck"
        "goimports"
    )
    
    for tool in "${go_tools[@]}"; do
        if sudo -u "$TARGET_USER" bash -c "source /etc/profile.d/go.sh && command -v $tool" &>/dev/null; then
            log_success "Go tool installed: $tool"
        else
            log_error "Go tool missing: $tool"
        fi
    done
}

check_neovim() {
    log_header "Neovim Configuration"
    
    if command -v nvim &>/dev/null; then
        local nvim_version
        nvim_version=$(nvim --version | head -n1)
        log_success "Neovim installed: $nvim_version"
        
        # Check configuration file
        local nvim_config="/home/${TARGET_USER}/.config/nvim/init.vim"
        if [[ -f "$nvim_config" ]]; then
            log_success "Neovim configuration file exists"
        else
            log_error "Neovim configuration file missing"
        fi
        
        # Check vim-plug installation
        local vim_plug="/home/${TARGET_USER}/.local/share/nvim/site/autoload/plug.vim"
        if [[ -f "$vim_plug" ]]; then
            log_success "vim-plug plugin manager installed"
        else
            log_error "vim-plug plugin manager missing"
        fi
    else
        log_error "Neovim is not installed"
    fi
}

check_python_environment() {
    log_header "Python Environment"
    
    if command -v python3 &>/dev/null; then
        local python_version
        python_version=$(python3 --version)
        log_success "Python installed: $python_version"
        
        # Check pip
        if sudo -u "$TARGET_USER" python3 -m pip --version &>/dev/null; then
            log_success "pip is available"
            
            # Check essential packages
            local python_packages=(
                "numpy"
                "pandas"
                "matplotlib"
                "scikit-learn"
                "jupyter"
                "ipython"
            )
            
            for package in "${python_packages[@]}"; do
                # Use correct import name for scikit-learn
                if [[ "$package" == "scikit-learn" ]]; then
                    import_name="sklearn"
                else
                    import_name="$package"
                fi
                if sudo -u "$TARGET_USER" python3 -c "import $import_name" &>/dev/null; then
                    log_success "Python package installed: $package"
                else
                    log_warning "Python package missing or not importable: $package"
                fi
            done
        else
            log_error "pip is not available"
        fi
    else
        log_error "Python3 is not installed"
    fi
}

check_shell_configuration() {
    log_header "Shell Configuration"
    
    # Check Oh My Zsh installation
    local omz_dir="/home/${TARGET_USER}/.oh-my-zsh"
    if [[ -d "$omz_dir" ]]; then
        log_success "Oh My Zsh installed"
    else
        log_error "Oh My Zsh not installed"
    fi
    
    # Check .zshrc file
    local zshrc="/home/${TARGET_USER}/.zshrc"
    if [[ -f "$zshrc" ]]; then
        log_success ".zshrc file exists"
        
        # Check for custom configurations
        if grep -q "GOPATH" "$zshrc"; then
            log_success ".zshrc contains GOPATH configuration"
        else
            log_warning ".zshrc missing GOPATH configuration"
        fi
        
        if grep -q "XDG_CONFIG_HOME" "$zshrc"; then
            log_success ".zshrc contains XDG configuration"
        else
            log_warning ".zshrc missing XDG configuration"
        fi
    else
        log_error ".zshrc file missing"
    fi
}

check_enhanced_tools() {
    log_header "Enhanced CLI Tools"
    
    local tools=(
        "rg:ripgrep"
        "fd:fd-find"
        "bat:bat"
        "exa:exa"
        "http:httpie"
    )
    
    for tool_info in "${tools[@]}"; do
        local tool_cmd="${tool_info%:*}"
        local tool_name="${tool_info#*:}"
        
        if command -v "$tool_cmd" &>/dev/null; then
            log_success "Enhanced tool installed: $tool_name ($tool_cmd)"
        else
            log_warning "Enhanced tool missing: $tool_name ($tool_cmd)"
        fi
    done
}

check_log_file() {
    log_header "Installation Log"
    
    local startup_log="/var/log/dev-vm-startup.log"
    if [[ -f "$startup_log" ]]; then
        log_success "Startup script log file exists: $startup_log"
        local log_size
        log_size=$(du -h "$startup_log" | cut -f1)
        log_info "Log file size: $log_size"
    else
        log_warning "Startup script log file not found: $startup_log"
    fi
}

# Main verification function
main() {
    echo -e "${BLUE}Developer VM Installation Verification${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo "Verification log: $VERIFICATION_LOG"
    echo ""
    
    check_user
    check_xdg_directories
    check_system_packages
    check_go_installation
    check_go_tools
    check_neovim
    check_python_environment
    check_shell_configuration
    check_enhanced_tools
    check_log_file
    
    echo ""
    echo -e "${BLUE}Verification completed. Check $VERIFICATION_LOG for detailed results.${NC}"
    
    # Summary
    local success_count error_count warning_count
    success_count=$(grep -c "✓" "$VERIFICATION_LOG" || echo "0")
    error_count=$(grep -c "✗" "$VERIFICATION_LOG" || echo "0")
    warning_count=$(grep -c "⚠" "$VERIFICATION_LOG" || echo "0")
    
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo -e "${GREEN}  Success: $success_count${NC}"
    echo -e "${YELLOW}  Warnings: $warning_count${NC}"
    echo -e "${RED}  Errors: $error_count${NC}"
    
    if [[ $error_count -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}🎉 All critical components are properly installed!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}❌ Some critical components are missing. Please check the log for details.${NC}"
        return 1
    fi
}

# Run verification
main "$@"