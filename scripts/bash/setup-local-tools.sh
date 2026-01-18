#!/bin/bash
# Azure Essentials - Local Tools Setup Script
# Code to Cloud
#
# This script installs the required tools for the Azure Essentials course.
# Supported platforms: macOS, Linux (Ubuntu/Debian)

set -e

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

echo -e "${BLUE}"
echo "=========================================="
echo "  Azure Essentials - Environment Setup   "
echo "  Code to Cloud                          "
echo "=========================================="
echo -e "${NC}"

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "redhat"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo -e "${YELLOW}Detected OS: ${OS}${NC}"

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew (macOS)
install_homebrew() {
    if ! command_exists brew; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}✓ Homebrew already installed${NC}"
    fi
}

# Install Azure CLI
install_azure_cli() {
    if ! command_exists az; then
        echo -e "${YELLOW}Installing Azure CLI...${NC}"
        case $OS in
            macos)
                brew install azure-cli
                ;;
            debian)
                curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
                ;;
            *)
                echo -e "${RED}Please install Azure CLI manually: https://learn.microsoft.com/cli/azure/install-azure-cli${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ Azure CLI already installed ($(az version --query '"azure-cli"' -o tsv))${NC}"
    fi
}

# Install Azure Developer CLI (azd)
install_azd() {
    if ! command_exists azd; then
        echo -e "${YELLOW}Installing Azure Developer CLI (azd)...${NC}"
        case $OS in
            macos)
                brew tap azure/azd && brew install azd
                ;;
            debian)
                curl -fsSL https://aka.ms/install-azd.sh | bash
                ;;
            *)
                echo -e "${RED}Please install azd manually: https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ Azure Developer CLI already installed ($(azd version))${NC}"
    fi
}

# Install kubectl
install_kubectl() {
    if ! command_exists kubectl; then
        echo -e "${YELLOW}Installing kubectl...${NC}"
        case $OS in
            macos)
                brew install kubectl
                ;;
            debian)
                sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
                curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
                sudo apt-get update && sudo apt-get install -y kubectl
                ;;
            *)
                echo -e "${RED}Please install kubectl manually: https://kubernetes.io/docs/tasks/tools/${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ kubectl already installed ($(kubectl version --client --short 2>/dev/null || echo 'installed'))${NC}"
    fi
}

# Install Docker
install_docker() {
    if ! command_exists docker; then
        echo -e "${YELLOW}Docker not found.${NC}"
        echo -e "${YELLOW}Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/${NC}"
    else
        echo -e "${GREEN}✓ Docker already installed ($(docker version --format '{{.Client.Version}}' 2>/dev/null || echo 'installed'))${NC}"
    fi
}

# Install Git
install_git() {
    if ! command_exists git; then
        echo -e "${YELLOW}Installing Git...${NC}"
        case $OS in
            macos)
                brew install git
                ;;
            debian)
                sudo apt-get update && sudo apt-get install -y git
                ;;
            *)
                echo -e "${RED}Please install Git manually: https://git-scm.com/downloads${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ Git already installed ($(git --version))${NC}"
    fi
}

# Install Python
install_python() {
    if ! command_exists python3; then
        echo -e "${YELLOW}Installing Python 3...${NC}"
        case $OS in
            macos)
                brew install python@3.11
                ;;
            debian)
                sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-venv
                ;;
            *)
                echo -e "${RED}Please install Python manually: https://www.python.org/downloads/${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ Python already installed ($(python3 --version))${NC}"
    fi
}

# Install jq (JSON processor)
install_jq() {
    if ! command_exists jq; then
        echo -e "${YELLOW}Installing jq...${NC}"
        case $OS in
            macos)
                brew install jq
                ;;
            debian)
                sudo apt-get update && sudo apt-get install -y jq
                ;;
            *)
                echo -e "${RED}Please install jq manually${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ jq already installed${NC}"
    fi
}

# Install Visual Studio Code
install_vscode() {
    # On macOS, check for the .app even if 'code' command isn't in PATH
    if [[ "$OS" == "macos" ]] && [[ -d "/Applications/Visual Studio Code.app" ]]; then
        echo -e "${GREEN}✓ VS Code already installed${NC}"
        # Suggest adding 'code' to PATH if not available
        if ! command_exists code; then
            echo -e "${YELLOW}  Tip: Add 'code' to PATH via: VS Code > Command Palette > 'Shell Command: Install'${NC}"
        fi
        return
    fi

    if ! command_exists code; then
        echo -e "${YELLOW}Installing Visual Studio Code...${NC}"
        case $OS in
            macos)
                brew install --cask visual-studio-code
                ;;
            debian)
                sudo apt-get install -y software-properties-common apt-transport-https wget
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
                sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
                sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                sudo apt-get update && sudo apt-get install -y code
                ;;
            *)
                echo -e "${YELLOW}Please install VS Code manually: https://code.visualstudio.com/${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ VS Code already installed${NC}"
    fi
}

# Main installation
echo ""
echo -e "${BLUE}Installing required tools...${NC}"
echo ""

# macOS specific
if [[ "$OS" == "macos" ]]; then
    install_homebrew
fi

install_git
install_azure_cli
install_azd
install_vscode
install_kubectl
install_docker
install_python
install_jq

# Install Bicep CLI via Azure CLI
echo ""
echo -e "${YELLOW}Installing/updating Bicep CLI...${NC}"
az bicep install 2>/dev/null || az bicep upgrade 2>/dev/null || echo -e "${GREEN}✓ Bicep CLI ready${NC}"

# Summary
echo ""
echo -e "${BLUE}=========================================="
echo "  Installation Summary"
echo "==========================================${NC}"
echo ""

tools=("az" "azd" "git" "code" "kubectl" "docker" "python3" "jq")
all_installed=true

for tool in "${tools[@]}"; do
    if command_exists "$tool"; then
        echo -e "${GREEN}✓ $tool${NC}"
    # Special case for VS Code on macOS - check for .app even if 'code' not in PATH
    elif [[ "$tool" == "code" ]] && [[ "$OS" == "macos" ]] && [[ -d "/Applications/Visual Studio Code.app" ]]; then
        echo -e "${GREEN}✓ $tool (app installed, 'code' CLI not in PATH)${NC}"
    else
        echo -e "${RED}✗ $tool (not installed)${NC}"
        all_installed=false
    fi
done

echo ""

if $all_installed; then
    echo -e "${GREEN}All tools installed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Run: az login"
    echo "2. Run: azd auth login"
    echo "3. Run: ./scripts/bash/validate-env.sh"
else
    echo -e "${YELLOW}Some tools could not be installed automatically.${NC}"
    echo "Please install them manually and run this script again."
fi

echo ""
