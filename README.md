# GCP Scripts

A collection of helpful Google Cloud Platform (GCP) scripts for various automation and development tasks.

## Scripts

### Developer VM Instance Startup Script

**`dev-vm-startup.sh`** - Comprehensive startup script for setting up a GCP VM development environment.

- **Target OS**: Ubuntu 24.04 LTS minimal
- **Focus**: Go and AI development
- **User**: dnjmn
- **Features**: Complete development environment with Go, Python, Neovim, and essential tools

📖 **[Detailed Documentation](README-dev-vm.md)**

#### Quick Start
```bash
# Run the startup script
sudo ./dev-vm-startup.sh

# Verify installation
./verify-installation.sh
```

#### What's Included
- **Go** (latest) with development tools (gopls, delve, staticcheck)
- **Neovim** (latest) with plugins for Go/Python development
- **Python 3** with AI/ML packages (numpy, pandas, scikit-learn, jupyter)
- **Enhanced Shell** (zsh with Oh My Zsh)
- **CLI Tools** (ripgrep, fd, bat, exa, httpie)
- **XDG Base Directory** compliance
- **Comprehensive logging** and error handling

## Repository Structure

```
gcp_scripts/
├── dev-vm-startup.sh      # Main development VM setup script
├── verify-installation.sh # Installation verification script
├── README-dev-vm.md       # Detailed documentation for dev VM
├── REQUIREMENTS.md        # Technical requirements document
└── README.md             # This file
```

## Contributing

Feel free to contribute additional GCP scripts and improvements:

1. Fork the repository
2. Create a feature branch
3. Add your script with documentation
4. Submit a pull request

## License

See [LICENSE](LICENSE) file for details.
