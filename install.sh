#!/usr/bin/env bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     NixOS Configuration - Post-Installation Setup           ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root!"
    print_info "Run as your regular user: ./install.sh"
    exit 1
fi

print_header

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_HOSTNAME=$(hostname)
CONFIG_HOSTNAME="muggy-nixos"
FLAKE_NAME="muggy-nixos"

print_info "Starting post-installation setup..."
print_info "Script location: $SCRIPT_DIR"
print_info "Current hostname: $CURRENT_HOSTNAME"

# Step 0: Personalize username
# ... (already there, skipping to next part in actual file)

# Step 0.5: Personalize hostname
print_info "\nStep 0.5: Personalizing hostname..."
read -p "Enter your desired hostname (default: $CONFIG_HOSTNAME): " FINAL_HOSTNAME
if [ -z "$FINAL_HOSTNAME" ]; then
    FINAL_HOSTNAME="$CONFIG_HOSTNAME"
fi

if [ "$FINAL_HOSTNAME" != "$CONFIG_HOSTNAME" ]; then
    print_info "Renaming host configuration from '$CONFIG_HOSTNAME' to '$FINAL_HOSTNAME'..."
    
    # Rename directory
    mv "$SCRIPT_DIR/hosts/$CONFIG_HOSTNAME" "$SCRIPT_DIR/hosts/$FINAL_HOSTNAME"
    
    # Update all file references
    # We use grep to find files and sed to replace
    # Target files based on previous search: flake.nix, modules/nh.nix, modules/terminal.nix, and the new hosts folder
    print_info "Updating file references..."
    sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/flake.nix"
    sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/modules/nh.nix"
    sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/modules/terminal.nix"
    sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/hosts/$FINAL_HOSTNAME/default.nix"
    
    # Update script variables for the rest of the execution
    CONFIG_HOSTNAME="$FINAL_HOSTNAME"
    FLAKE_NAME="$FINAL_HOSTNAME"
    print_success "Hostname personalization complete!"
else
    print_info "Using default hostname: $CONFIG_HOSTNAME"
fi

# Step 1: Generate hardware configuration
print_info "\nStep 1: Generating hardware configuration..."
HARDWARE_CONFIG="$SCRIPT_DIR/hosts/$CONFIG_HOSTNAME/hardware-configuration.nix"

if [ -f "$HARDWARE_CONFIG" ]; then
    print_warning "hardware-configuration.nix already exists!"
    read -p "Overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing hardware configuration"
    else
        sudo nixos-generate-config --show-hardware-config > "$HARDWARE_CONFIG"
        print_success "Hardware configuration regenerated!"
    fi
else
    sudo nixos-generate-config --show-hardware-config > "$HARDWARE_CONFIG"
    print_success "Hardware configuration generated!"
fi

# Step 2: Check if flakes are supported
print_info "\nStep 2: Checking flakes configuration..."
EXTRA_FLAGS="--extra-experimental-features 'nix-command flakes'"

# Try to use nix flake command
if nix flake metadata "$SCRIPT_DIR" $EXTRA_FLAGS &>/dev/null; then
    print_success "Flakes are supported!"
else
    print_error "Nix command not found or not working properly!"
    exit 1
fi

# Step 3: Verify hostname
print_info "\nStep 3: Verifying hostname..."
if [ "$(hostname)" != "$CONFIG_HOSTNAME" ]; then
    print_warning "Hostname mismatch!"
    print_info "Current: $CURRENT_HOSTNAME"
    print_info "Config:  $CONFIG_HOSTNAME"
    print_info "The hostname will be changed to '$CONFIG_HOSTNAME' after rebuild."
    echo ""
    read -p "Continue? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Aborted by user."
        exit 0
    fi
fi

# Step 4: Build and switch
print_info "\nStep 4: Building and switching to new configuration..."
print_warning "This may take a while on first build..."
echo ""

BUILD_CMD="sudo nixos-rebuild switch --flake $SCRIPT_DIR#$FLAKE_NAME $EXTRA_FLAGS"

print_info "Running: $BUILD_CMD"
echo ""

if eval $BUILD_CMD; then
    print_success "\n✨ Configuration successfully applied!"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review any warnings or errors above"
    echo "2. Reboot to ensure all changes take effect:"
    echo -e "   ${YELLOW}sudo reboot${NC}"
    echo ""
    print_success "Setup completed successfully! 🎉"
else
    print_error "Failed to rebuild system configuration!"
    print_info "Check the errors above and fix any issues."
    print_info "You can manually retry with:"
    echo -e "   ${YELLOW}$BUILD_CMD${NC}"
    exit 1
fi
