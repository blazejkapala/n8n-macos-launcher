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
DIM='\033[2m'
BLINK='\033[5m'

# Symbols
CHECK_MARK="${GREEN}✓${NC}"
CROSS_MARK="${RED}✗${NC}"
ARROW="${CYAN}➜${NC}"
STAR="${YELLOW}★${NC}"
ROCKET="${MAGENTA}🚀${NC}"

# Extended icons
ICON_CHECK="✔"
ICON_CROSS="✖"
ICON_ARROW="▸"
ICON_STAR="★"
ICON_ROCKET="🚀"
ICON_WARN="⚠"
ICON_INFO="ℹ"
ICON_GEAR="⚙"
ICON_DOWNLOAD="⬇"
ICON_PACKAGE="📦"
ICON_DOCKER="🐳"
ICON_NODE="⬢"
ICON_DIAMOND="◆"

# Configuration
N8N_PORT="${N8N_PORT:-5678}"
N8N_VERSION="latest"
INSTALLATION_METHOD=""

# ═══════════════════════════════════════════════════════════════════════════════
# Animation Functions
# ═══════════════════════════════════════════════════════════════════════════════

# Spinner animation for background tasks
spin() {
    local pid=$1
    local message="$2"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${frames[$i]}${NC} %s" "$message"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.1
    done
    printf "\r\033[K"
}

# Progress bar animation
progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    printf "\r  ${CYAN}[${NC}"
    printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "${CYAN}]${NC} ${BOLD}%3d%%${NC}" "$percent"
}

# Typewriter effect for dramatic text
typewriter() {
    local text="$1"
    local delay=${2:-0.03}
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# Gradient text effect (cycles through colors)
print_gradient() {
    local text="$1"
    local colors=("$CYAN" "$BLUE" "$MAGENTA" "$RED" "$YELLOW" "$GREEN")
    local len=${#text}
    local color_count=${#colors[@]}
    for ((i=0; i<len; i++)); do
        local color_index=$((i % color_count))
        printf "%b%s" "${colors[$color_index]}" "${text:$i:1}"
    done
    printf "%b\n" "$NC"
}

# Startup animation with progress bar
startup_animation() {
    local steps=("Initializing" "Loading components" "Preparing environment" "Starting n8n Launcher")
    local total=${#steps[@]}
    echo ""
    for ((i=0; i<total; i++)); do
        progress_bar $((i + 1)) $total
        printf "  ${DIM}%s${NC}" "${steps[$i]}"
        sleep 0.3
    done
    printf "\r\033[K"
    echo ""
}

# Print fancy box
print_fancy_box() {
    local title="$1"
    local icon="${2:-$ICON_DIAMOND}"
    local width=45
    echo ""
    echo -e "  ${CYAN}╭$(printf '─%.0s' $(seq 1 $width))╮${NC}"
    printf "  ${CYAN}│${NC}  ${BOLD}%s${NC}  %-*s${CYAN}│${NC}\n" "$icon" "$((width - 5))" "$title"
    echo -e "  ${CYAN}╰$(printf '─%.0s' $(seq 1 $width))╯${NC}"
}

# Print terminal warning (critical message about not closing)
print_terminal_warning() {
    echo ""
    echo -e "  ${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${RED}║${NC}                                                               ${RED}║${NC}"
    echo -e "  ${RED}║${NC}   ${YELLOW}${BOLD}${ICON_WARN}  UWAGA: Zamknięcie tego terminala zatrzyma n8n!${NC}        ${RED}║${NC}"
    echo -e "  ${RED}║${NC}                                                               ${RED}║${NC}"
    echo -e "  ${RED}║${NC}   ${WHITE}Zostaw to okno otwarte, aby n8n działał w tle.${NC}            ${RED}║${NC}"
    echo -e "  ${RED}║${NC}   ${WHITE}Aby zatrzymać n8n, naciśnij:${NC} ${CYAN}${BOLD}Ctrl+C${NC}                       ${RED}║${NC}"
    echo -e "  ${RED}║${NC}                                                               ${RED}║${NC}"
    echo -e "  ${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print info box (for running status)
print_info_box() {
    local url="$1"
    local method="$2"
    echo ""
    echo -e "  ${GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "  ${GREEN}┃${NC}                                                             ${GREEN}┃${NC}"
    echo -e "  ${GREEN}┃${NC}  ${ICON_ROCKET} ${BOLD}${WHITE}n8n is running at:${NC}                                   ${GREEN}┃${NC}"
    echo -e "  ${GREEN}┃${NC}     ${CYAN}${BOLD}$url${NC}                                  ${GREEN}┃${NC}"
    echo -e "  ${GREEN}┃${NC}                                                             ${GREEN}┃${NC}"
    if [[ "$method" == "docker" ]]; then
        echo -e "  ${GREEN}┃${NC}  ${ICON_DOCKER} ${DIM}Running in Docker container${NC}                          ${GREEN}┃${NC}"
    else
        echo -e "  ${GREEN}┃${NC}  ${ICON_NODE} ${DIM}Running natively with Node.js${NC}                         ${GREEN}┃${NC}"
    fi
    echo -e "  ${GREEN}┃${NC}                                                             ${GREEN}┃${NC}"
    echo -e "  ${GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Helper functions
print_header() {
    clear
    echo ""
    echo -e "${CYAN}"
    echo -e "    ╭────────────────────────────────────╮"
    echo -e "    │                                    │"
    echo -e "    │  ${WHITE}███╗   ██╗${NC} ${RED}█████╗ ${NC} ${WHITE}███╗   ██╗${CYAN}    │"
    echo -e "    │  ${WHITE}████╗  ██║${NC}${RED}██╔══██╗${NC} ${WHITE}████╗  ██║${CYAN}    │"
    echo -e "    │  ${WHITE}██╔██╗ ██║${NC}${RED}╚█████╔╝${NC} ${WHITE}██╔██╗ ██║${CYAN}    │"
    echo -e "    │  ${WHITE}██║╚██╗██║${NC}${RED}██╔══██╗${NC} ${WHITE}██║╚██╗██║${CYAN}    │"
    echo -e "    │  ${WHITE}██║ ╚████║${NC}${RED}╚█████╔╝${NC} ${WHITE}██║ ╚████║${CYAN}    │"
    echo -e "    │  ${WHITE}╚═╝  ╚═══╝${NC} ${RED}╚════╝ ${NC} ${WHITE}╚═╝  ╚═══╝${CYAN}    │"
    echo -e "    │                                    │"
    echo -e "    │  ${MAGENTA}🚀 LAUNCHER${CYAN}          ${DIM}for macOS${NC}${CYAN}   │"
    echo -e "    │                                    │"
    echo -e "    ╰────────────────────────────────────╯"
    echo -e "${NC}"
    echo ""

    # Startup animation
    startup_animation
}

print_section() {
    local title="$1"
    local width=47
    local title_len=${#title}
    local padding=$((width - title_len - 5))
    echo ""
    echo -e "  ${CYAN}╭$(printf '─%.0s' $(seq 1 $width))╮${NC}"
    printf "  ${CYAN}│${NC}  ${ICON_DIAMOND}  ${BOLD}${WHITE}%s${NC}%*s${CYAN}│${NC}\n" "$title" "$padding" ""
    echo -e "  ${CYAN}╰$(printf '─%.0s' $(seq 1 $width))╯${NC}"
    echo ""
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

# Choose installation method
choose_installation_method() {
    print_section "Choose Installation Method"
    
    echo ""
    echo -e "${BOLD}${CYAN}1)${NC} ${WHITE}Native Installation${NC}"
    echo -e "   ${CYAN}→${NC} Installs Node.js and n8n directly on your system"
    echo -e "   ${GREEN}+${NC} Faster startup"
    echo -e "   ${GREEN}+${NC} Better macOS integration"
    echo -e "   ${YELLOW}−${NC} Requires Node.js 18+"
    echo ""
    echo -e "${BOLD}${CYAN}2)${NC} ${WHITE}Docker Installation${NC}"
    echo -e "   ${CYAN}→${NC} Runs n8n in an isolated Docker container"
    echo -e "   ${GREEN}+${NC} Isolated environment"
    echo -e "   ${GREEN}+${NC} Easy updates and cleanup"
    echo -e "   ${GREEN}+${NC} No Node.js required"
    echo -e "   ${YELLOW}−${NC} Requires Docker Desktop"
    echo ""
    
    ask_question "Choose installation method (1 or 2):"
    read -r choice
    
    case $choice in
        1)
            INSTALLATION_METHOD="native"
            print_success "Selected: Native Installation"
            ;;
        2)
            INSTALLATION_METHOD="docker"
            print_success "Selected: Docker Installation"
            ;;
        *)
            print_error "Invalid choice. Please enter 1 or 2."
            choose_installation_method
            ;;
    esac
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
        ask_question "Would you like to install Homebrew? (y/N)"
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
        
        # Check if version is compatible with n8n (requires 18, 20, or 22)
        major_version=$(echo $node_version | cut -d'v' -f2 | cut -d'.' -f1)
        
        if [ "$major_version" -lt 18 ]; then
            print_error "Node.js version $node_version is too old!"
            print_warning "n8n requires Node.js v18.17+, v20, or v22"
            ask_question "Would you like to install a compatible Node.js version? (y/N)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                install_nodejs
                return 0
            else
                return 1
            fi
        elif [ "$major_version" -eq 18 ] || [ "$major_version" -eq 20 ] || [ "$major_version" -eq 22 ]; then
            print_success "Node.js version is compatible with n8n (v$major_version)"
            return 0
        elif [ "$major_version" -gt 22 ]; then
            print_error "Node.js version $node_version is too new!"
            print_warning "n8n currently supports v18.17+, v20, or v22 only"
            print_warning "Your current version: v$major_version"
            echo ""
            print_info "💡 Recommended: Use Docker installation instead (no Node.js version issues)"
            echo ""
            ask_question "Would you like to downgrade to a compatible Node.js version? (y/N)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                install_nodejs_compatible
                return 0
            else
                print_warning "Continuing with incompatible Node.js version - n8n may not work!"
                ask_question "Continue anyway? (y/N)"
                read -r continue_response
                if [[ "$continue_response" =~ ^[Yy]$ ]]; then
                    return 0
                else
                    return 1
                fi
            fi
        else
            print_warning "Node.js version $node_version - compatibility unknown"
            print_info "n8n officially supports v18.17+, v20, or v22"
            return 0
        fi
    else
        print_warning "Node.js is not installed"
        ask_question "Would you like to install Node.js? (y/N)"
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
        print_info "Installing Node.js LTS via Homebrew..."
        print_warning "Note: Installing node@20 (LTS) for n8n compatibility"
        brew install node@20
        
        # Link node@20
        brew link --overwrite node@20 --force
        
        # Update PATH
        echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zprofile
        export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
        
        print_success "Node.js 20 (LTS) installed successfully"
        
        # Verify installation
        if command -v node &> /dev/null; then
            new_version=$(node --version)
            print_success "Active Node.js version: $new_version"
        fi
    else
        print_error "Homebrew is not available. Install Node.js manually from https://nodejs.org"
        return 1
    fi
}

install_nodejs_compatible() {
    if command -v brew &> /dev/null; then
        print_section "Installing Compatible Node.js Version"
        
        echo ""
        echo -e "${BOLD}${CYAN}Choose Node.js version:${NC}"
        echo -e "  ${CYAN}1)${NC} Node.js 20 (LTS) ${GREEN}← Recommended${NC}"
        echo -e "  ${CYAN}2)${NC} Node.js 22 (Current)"
        echo -e "  ${CYAN}3)${NC} Node.js 18 (Older LTS)"
        echo ""
        
        ask_question "Choose version (1-3, default: 1):"
        read -r choice
        
        case ${choice:-1} in
            1)
                node_version="20"
                ;;
            2)
                node_version="22"
                ;;
            3)
                node_version="18"
                ;;
            *)
                node_version="20"
                ;;
        esac
        
        print_info "Uninstalling current Node.js version..."
        brew uninstall --ignore-dependencies node 2>/dev/null || true
        
        print_info "Installing Node.js $node_version via Homebrew..."
        brew install node@$node_version
        
        # Link the specific version
        brew unlink node 2>/dev/null || true
        brew link --overwrite node@$node_version --force
        
        # Update PATH for the specific version
        if [[ "$node_version" != "22" ]]; then
            echo "export PATH=\"/opt/homebrew/opt/node@$node_version/bin:\$PATH\"" >> ~/.zprofile
            export PATH="/opt/homebrew/opt/node@$node_version/bin:$PATH"
        fi
        
        print_success "Node.js $node_version installed successfully"
        
        # Verify installation
        if command -v node &> /dev/null; then
            new_version=$(node --version)
            print_success "Active Node.js version: $new_version"
        else
            print_warning "Please restart your terminal or run: source ~/.zprofile"
        fi
    else
        print_error "Homebrew is not available"
        print_info "Please use nvm to manage Node.js versions: https://github.com/nvm-sh/nvm"
        return 1
    fi
}

# Check if n8n is installed
check_n8n() {
    print_section "Checking n8n"
    
    if command -v n8n &> /dev/null; then
        n8n_version=$(n8n --version 2>/dev/null || echo "unknown")
        print_success "n8n installed: version $n8n_version"
        
        # Check for updates
        check_n8n_update
        
        return 0
    else
        print_warning "n8n is not installed"
        ask_question "Would you like to install n8n? (y/N)"
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

# Check for n8n updates (Native)
check_n8n_update() {
    print_info "Checking for n8n updates..."
    
    # Get current version
    current_version=$(n8n --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$current_version" ]]; then
        print_warning "Could not determine current n8n version"
        return 0
    fi
    
    # Get latest version from npm
    latest_version=$(npm view n8n version 2>/dev/null)
    
    if [[ -z "$latest_version" ]]; then
        print_warning "Could not check for updates (npm registry unavailable)"
        return 0
    fi
    
    # Compare versions
    if [[ "$current_version" != "$latest_version" ]]; then
        echo ""
        print_warning "New n8n version available!"
        echo -e "  ${YELLOW}Current version:${NC} $current_version"
        echo -e "  ${GREEN}Latest version:${NC}  $latest_version"
        echo ""
        
        ask_question "Would you like to update n8n now? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            update_n8n
        else
            print_info "You can update later with: npm update -g n8n"
        fi
    else
        print_success "n8n is up to date (v$current_version)"
    fi
}

# Update n8n (Native)
update_n8n() {
    print_section "Updating n8n"
    
    print_info "Updating n8n to latest version..."
    npm install -g n8n@latest
    
    new_version=$(n8n --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    print_success "n8n updated to version $new_version"
}

install_n8n() {
    print_info "Installing n8n globally via npm..."
    npm install -g n8n
    print_success "n8n installed successfully"
}

# Check if Docker is installed
check_docker() {
    print_section "Checking Docker"
    
    if command -v docker &> /dev/null; then
        # Check if Docker daemon is running
        if docker info &> /dev/null; then
            docker_version=$(docker --version)
            print_success "Docker installed and running: $docker_version"
            return 0
        else
            print_warning "Docker is installed but not running"
            echo ""
            ask_question "Would you like to start Docker Desktop now? (y/N)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                print_info "Starting Docker Desktop..."
                open -a Docker
                echo ""
                print_info "Waiting for Docker to start (this may take a moment)..."

                # Wait for Docker to be ready (max 60 seconds)
                local wait_time=0
                local max_wait=60
                while ! docker info &> /dev/null; do
                    sleep 2
                    wait_time=$((wait_time + 2))
                    printf "\r  ${CYAN}⏳${NC} Waiting... ${DIM}%ds${NC}  " "$wait_time"
                    if [ $wait_time -ge $max_wait ]; then
                        echo ""
                        print_error "Docker did not start within ${max_wait}s"
                        print_info "Please start Docker Desktop manually and try again."
                        return 1
                    fi
                done
                printf "\r\033[K"
                print_success "Docker is now running!"
                docker_version=$(docker --version)
                print_success "Docker version: $docker_version"
                return 0
            else
                print_error "Docker is required but not running"
                print_info "Start Docker Desktop manually and run this script again."
                return 1
            fi
        fi
    else
        print_warning "Docker is not installed"
        ask_question "Would you like to install Docker Desktop? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_docker
            return 0
        else
            print_error "Docker is required for Docker installation method"
            return 1
        fi
    fi
}

install_docker() {
    if command -v brew &> /dev/null; then
        print_info "Installing Docker Desktop via Homebrew..."
        brew install --cask docker
        print_success "Docker Desktop installed successfully"

        print_info "Starting Docker Desktop..."
        open -a Docker
        echo ""
        print_info "Waiting for Docker to start (first launch may take longer)..."

        # Wait for Docker to be ready (max 90 seconds for first launch)
        local wait_time=0
        local max_wait=90
        while ! docker info &> /dev/null; do
            sleep 2
            wait_time=$((wait_time + 2))
            printf "\r  ${CYAN}⏳${NC} Waiting... ${DIM}%ds${NC}  " "$wait_time"
            if [ $wait_time -ge $max_wait ]; then
                echo ""
                print_warning "Docker is taking longer than expected"
                print_info "Please wait for Docker Desktop to fully start, then run this script again."
                return 1
            fi
        done
        printf "\r\033[K"
        print_success "Docker is now running!"
    else
        print_error "Homebrew is not available"
        print_info "Please install Docker Desktop manually from: https://www.docker.com/products/docker-desktop"
        return 1
    fi
}

# Check if n8n Docker image exists
check_n8n_docker() {
    print_section "Checking n8n Docker Image"
    
    if docker images n8nio/n8n --format "{{.Repository}}" 2>/dev/null | grep -q "n8nio/n8n"; then
        print_success "n8n Docker image found"
        
        # Check for updates
        check_n8n_docker_update
        
        return 0
    else
        print_info "n8n Docker image not found"
        print_info "The image will be downloaded automatically on first run"
        return 0
    fi
}

# Check for n8n Docker image updates
check_n8n_docker_update() {
    print_info "Checking for Docker image updates..."
    
    # Get local image ID
    local_image=$(docker images n8nio/n8n:latest --format "{{.ID}}" 2>/dev/null | head -1)
    
    if [[ -z "$local_image" ]]; then
        print_info "No local image found, will download on first run"
        return 0
    fi
    
    # Pull latest image digest to compare (quiet mode)
    print_info "Checking Docker Hub for updates..."
    docker pull n8nio/n8n:latest --quiet 2>/dev/null
    
    # Get new image ID after pull
    new_image=$(docker images n8nio/n8n:latest --format "{{.ID}}" 2>/dev/null | head -1)
    
    if [[ "$local_image" != "$new_image" ]]; then
        echo ""
        print_success "n8n Docker image has been updated to the latest version!"
        print_info "New containers will use the updated image"
        echo ""
    else
        print_success "n8n Docker image is up to date"
    fi
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
    
    ask_question "Would you like to open the browser automatically? (y/N)"
    read -r open_browser
    
    # Check if data folder exists
    n8n_data_folder="$HOME/.n8n"
    if [ ! -d "$n8n_data_folder" ]; then
        print_info "Creating n8n data folder: $n8n_data_folder"
        mkdir -p "$n8n_data_folder"
    fi
    print_success "n8n data folder: $n8n_data_folder"
}

# Launch n8n with Docker
launch_n8n_docker() {
    print_section "Starting n8n (Docker)"

    print_info "Preparing Docker container..."

    # Verify Docker is running before proceeding
    if ! docker info &> /dev/null; then
        echo ""
        print_error "Docker is not running!"
        echo ""
        ask_question "Would you like to start Docker Desktop now? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_info "Starting Docker Desktop..."
            open -a Docker
            echo ""
            print_info "Waiting for Docker to start (this may take a moment)..."

            # Wait for Docker to be ready (max 60 seconds)
            local wait_time=0
            local max_wait=60
            while ! docker info &> /dev/null; do
                sleep 2
                wait_time=$((wait_time + 2))
                printf "\r  ${CYAN}⏳${NC} Waiting... ${DIM}%ds${NC}  " "$wait_time"
                if [ $wait_time -ge $max_wait ]; then
                    echo ""
                    print_error "Docker did not start within ${max_wait}s"
                    print_info "Please start Docker Desktop manually and try again."
                    return 1
                fi
            done
            printf "\r\033[K"
            print_success "Docker is now running!"
            echo ""
        else
            print_warning "Please start Docker Desktop and try again."
            echo ""
            print_info "To start Docker Desktop:"
            echo -e "    ${CYAN}${ICON_ARROW}${NC} Open ${WHITE}Docker Desktop${NC} from Applications"
            echo -e "    ${CYAN}${ICON_ARROW}${NC} Or run: ${WHITE}open -a Docker${NC}"
            echo ""
            return 1
        fi
    fi

    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q '^n8n$'; then
        print_info "Existing n8n container found"

        # Check if it's running
        if docker ps --format '{{.Names}}' | grep -q '^n8n$'; then
            print_warning "n8n container is already running"
            ask_question "Would you like to restart it? (y/N)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                print_info "Stopping existing container..."
                docker stop n8n
                docker rm n8n
            else
                print_info "Attaching to running container..."
                if [[ "$open_browser" =~ ^[Yy]$ ]]; then
                    open "http://localhost:$N8N_PORT" &
                fi

                # Show info box
                print_info_box "http://localhost:$N8N_PORT" "docker"

                # Show terminal warning - this is critical!
                print_terminal_warning

                docker logs -f n8n
                return 0
            fi
        else
            print_info "Removing stopped container..."
            docker rm n8n
        fi
    fi

    print_success "Starting new n8n container..."
    echo ""
    echo -e "  ${ICON_ROCKET} ${BOLD}${MAGENTA}Launching n8n in Docker...${NC}"

    # Show info box
    print_info_box "http://localhost:$N8N_PORT" "docker"

    # Show Docker-specific info
    echo ""
    echo -e "  ${DIM}Docker commands:${NC}"
    echo -e "    ${CYAN}${ICON_ARROW}${NC} Stop n8n:    ${WHITE}docker stop n8n${NC}"
    echo -e "    ${CYAN}${ICON_ARROW}${NC} View logs:   ${WHITE}docker logs -f n8n${NC}"

    # Show terminal warning - this is critical!
    print_terminal_warning

    # Open browser if requested
    if [[ "$open_browser" =~ ^[Yy]$ ]]; then
        sleep 5
        open "http://localhost:$N8N_PORT" &
    fi

    # Run Docker container
    docker run -it --rm \
        --name n8n \
        -p $N8N_PORT:5678 \
        -v ~/.n8n:/home/node/.n8n \
        n8nio/n8n
}

# Launch n8n (native)
launch_n8n() {
    print_section "Starting n8n (Native)"

    print_info "Preparing environment..."

    # Export environment variables
    export N8N_PORT="$N8N_PORT"

    print_success "Everything is ready!"
    echo ""
    echo -e "  ${ICON_ROCKET} ${BOLD}${MAGENTA}Launching n8n...${NC}"

    # Show info box
    print_info_box "http://localhost:$N8N_PORT" "native"

    # Show terminal warning - this is critical!
    print_terminal_warning

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
    
    if [[ "$INSTALLATION_METHOD" == "docker" ]]; then
        if command -v docker &> /dev/null; then
            echo -e "  ${CHECK_MARK} Docker: $(docker --version | awk '{print $3}' | sed 's/,//')"
        fi
        echo -e "  ${CHECK_MARK} n8n: Docker image (n8nio/n8n)"
    else
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
    
    # Choose installation method
    choose_installation_method
    
    if [[ "$INSTALLATION_METHOD" == "docker" ]]; then
        # Docker installation path
        if ! check_homebrew; then
            print_error "Cannot continue without Homebrew (needed to install Docker)"
            exit 1
        fi
        
        if ! check_docker; then
            print_error "Cannot continue without Docker"
            exit 1
        fi
        
        check_n8n_docker
        
    else
        # Native installation path
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
    fi
    
    show_summary
    
    # Configure and launch
    configure_n8n
    
    echo ""
    ask_question "Would you like to start n8n now? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if [[ "$INSTALLATION_METHOD" == "docker" ]]; then
            launch_n8n_docker
        else
            launch_n8n
        fi
    else
        echo ""
        print_success "Installation complete!"
        if [[ "$INSTALLATION_METHOD" == "docker" ]]; then
            print_info "To start n8n later, run: docker run -it --rm --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n n8nio/n8n"
            print_info "Or simply run this script again!"
        else
            print_info "To start n8n later, use the command: n8n start"
            print_info "Or simply run this script again!"
        fi
        echo ""
    fi
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}Interrupted by user${NC}"; exit 130' INT

# Run main function
main
