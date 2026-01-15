#!/bin/bash

# n8n macOS Launcher - Quick Installer
# This script downloads and runs the n8n launcher

set -e

REPO_URL="https://raw.githubusercontent.com/blazejkapala/n8n-macos-launcher/main"
SCRIPT_NAME="n8n-launcher.sh"
INSTALL_DIR="$HOME/.local/bin"

echo "🚀 n8n macOS Launcher - Quick Installer"
echo ""

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Download the script
echo "Downloading n8n launcher..."
curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"

# Make it executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Adding $INSTALL_DIR to PATH..."
    
    # Detect shell
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bash_profile"
    else
        SHELL_RC="$HOME/.profile"
    fi
    
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
    export PATH="$PATH:$INSTALL_DIR"
    
    echo "✓ PATH updated in $SHELL_RC"
    echo "  Run 'source $SHELL_RC' or restart your terminal to apply changes"
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "To launch n8n, run:"
echo "  $SCRIPT_NAME"
echo ""
echo "Or run directly:"
echo "  $INSTALL_DIR/$SCRIPT_NAME"
echo ""

# Ask if user wants to run now
read -p "Do you want to run n8n launcher now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$INSTALL_DIR/$SCRIPT_NAME"
fi
