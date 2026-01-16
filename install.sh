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
    
    # Detect shell config file
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_RC="$HOME/.bash_profile"
    else
        SHELL_RC="$HOME/.profile"
    fi
    
    # Check if already in shell config
    if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
        echo "✓ PATH updated in $SHELL_RC"
    fi
    
    export PATH="$PATH:$INSTALL_DIR"
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "To launch n8n, run:"
echo "  n8n-launcher.sh"
echo ""
echo "Or run directly:"
echo "  $INSTALL_DIR/n8n-launcher.sh"
echo ""
echo "Note: You may need to restart your terminal or run:"
echo "  source ~/.zshrc"
echo ""
