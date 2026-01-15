#!/bin/bash

# n8n Launcher for macOS
# Interactive script to check dependencies and launch n8n
# Compatible with Apple Silicon (M1/M2/M3)

set -e

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Symbols
CHECK_MARK="${GREEN}✓${NC}"
CROSS_MARK="${RED}✗${NC}"
ARROW="${CYAN}➜${NC}"
STAR="${YELLOW}★${NC}"
ROCKET="${MAGENTA}🚀${NC}"

# Configuration
N8N_PORT="${N8N_PORT:-5678}"
N8N_VERSION="latest"

# Helper functions
print_header() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║               n8n Launcher for macOS                      ║"
    echo "║          Workflow Automation Made Easy                    ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${BOLD}${WHITE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${CHECK_MARK} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${CROSS_MARK} ${RED}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  ${YELLOW}$1${NC}"
}

print_info() {
    echo -e "${ARROW} ${CYAN}$1${NC}"
}

ask_question() {
    echo -e "\n${STAR} ${YELLOW}$1${NC}"
    echo -n -e "${ARROW} "
}

# Check macOS version
check_macos() {
    print_section "Checking Operating System"
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script only works on macOS!"
        exit 1
    fi
    
    macos_version=$(sw_vers -productVersion)
    print_success "macOS detected: version $macos_version"
    
    # Check for Apple Silicon
    arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        print_success "Apple Silicon (M-series) processor detected"
    else
        print_info "Intel processor detected"
    fi
}

# Check if Homebrew is installed
check_homebrew() {
    print_section "Checking Homebrew"
    
    if command -v brew &> /dev/null; then
        brew_version=$(brew --version | head -n1)
        print_success "Homebrew installed: $brew_version"
        return 0
    else
        print_warning "Homebrew is not installed"
        ask_question "Would you like to install Homebrew? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add Homebrew to PATH for Apple Silicon
            if [[ "$arch" == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
            
            print_success "Homebrew installed successfully"
            return 0
        else
            print_error "Homebrew is required to continue"
            return 1
        fi
    fi
}

# Check if Node.js is installed
check_nodejs() {
    print_section "Checking Node.js"
    
    if command -v node &> /dev/null; then
        node_version=$(node --version)
        npm_version=$(npm --version)
        print_success "Node.js installed: $node_version"
        print_success "npm installed: v$npm_version"
        
        # Check if version is sufficient (n8n requires Node.js 18+)
        major_version=$(echo $node_version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$major_version" -ge 18 ]; then
            print_success "Node.js version is sufficient (requires 18+)"
            return 0
        else
            print_warning "Node.js version $node_version may be too old (requires 18+)"
            ask_question "Would you like to update Node.js? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                install_nodejs
                return 0
            fi
        fi
        return 0
    else
        print_warning "Node.js is not installed"
        ask_question "Would you like to install Node.js? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_nodejs
            return 0
        else
            print_error "Node.js is required to run n8n"
            return 1
        fi
    fi
}

install_nodejs() {
    if command -v brew &> /dev/null; then
        print_info "Installing Node.js via Homebrew..."
        brew install node
        print_success "Node.js installed successfully"
    else
        print_error "Homebrew is not available. Install Node.js manually from https://nodejs.org"
        return 1
    fi
}

# Check if n8n is installed
check_n8n() {
    print_section "Checking n8n"
    
    if command -v n8n &> /dev/null; then
        n8n_version=$(n8n --version 2>/dev/null || echo "unknown")
        print_success "n8n installed: version $n8n_version"
        return 0
    else
        print_warning "n8n is not installed"
        ask_question "Would you like to install n8n? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_n8n
            return 0
        else
            print_error "n8n is required to continue"
            return 1
        fi
    fi
}

install_n8n() {
    print_info "Installing n8n globally via npm..."
    npm install -g n8n
    print_success "n8n installed successfully"
}

# Configure n8n
configure_n8n() {
    print_section "Configuring n8n"
    
    ask_question "Which port would you like to run n8n on? (default: 5678)"
    read -r port
    if [[ -n "$port" ]]; then
        N8N_PORT="$port"
    fi
    print_info "n8n will run on port: $N8N_PORT"
    
    ask_question "Would you like to open the browser automatically? (y/n)"
    read -r open_browser
    
    # Check if data folder exists
    n8n_data_folder="$HOME/.n8n"
    if [ ! -d "$n8n_data_folder" ]; then
        print_info "Creating n8n data folder: $n8n_data_folder"
        mkdir -p "$n8n_data_folder"
    fi
    print_success "n8n data folder: $n8n_data_folder"
}

# Launch n8n
launch_n8n() {
    print_section "Starting n8n"
    
    print_info "Preparing environment..."
    
    # Export environment variables
    export N8N_PORT="$N8N_PORT"
    
    print_success "Everything is ready!"
    echo ""
    echo -e "${ROCKET} ${BOLD}${MAGENTA}Launching n8n...${NC}"
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}n8n will be available at:${NC}                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}${BOLD}http://localhost:$N8N_PORT${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}To stop n8n, press: Ctrl+C${NC}                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Open browser if requested
    if [[ "$open_browser" =~ ^[Yy]$ ]]; then
        sleep 3
        open "http://localhost:$N8N_PORT" &
    fi
    
    # Launch n8n
    n8n start
}

# Show summary
show_summary() {
    print_section "Installation Summary"
    
    echo -e "${GREEN}All components are installed:${NC}"
    echo ""
    
    if command -v brew &> /dev/null; then
        echo -e "  ${CHECK_MARK} Homebrew: $(brew --version | head -n1 | awk '{print $2}')"
    fi
    
    if command -v node &> /dev/null; then
        echo -e "  ${CHECK_MARK} Node.js: $(node --version)"
        echo -e "  ${CHECK_MARK} npm: v$(npm --version)"
    fi
    
    if command -v n8n &> /dev/null; then
        echo -e "  ${CHECK_MARK} n8n: version $(n8n --version 2>/dev/null || echo 'installed')"
    fi
    
    echo ""
}

# Main execution flow
main() {
    print_header
    
    echo -e "${BOLD}Welcome to n8n installer for macOS!${NC}"
    echo -e "This script will check and install all required components.\n"
    
    # Run checks
    check_macos
    
    if ! check_homebrew; then
        print_error "Cannot continue without Homebrew"
        exit 1
    fi
    
    if ! check_nodejs; then
        print_error "Cannot continue without Node.js"
        exit 1
    fi
    
    if ! check_n8n; then
        print_error "Cannot continue without n8n"
        exit 1
    fi
    
    show_summary
    
    # Configure and launch
    configure_n8n
    
    echo ""
    ask_question "Would you like to start n8n now? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        launch_n8n
    else
        echo ""
        print_success "Installation complete!"
        print_info "To start n8n later, use the command: n8n start"
        echo ""
    fi
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}Interrupted by user${NC}"; exit 130' INT

# Run main function
main
