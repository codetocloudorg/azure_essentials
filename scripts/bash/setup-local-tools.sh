#!/bin/bash
#===============================================================================
# Azure Essentials - Local Tools Setup Script
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# PURPOSE:
#   Installs and configures all required development tools for the Azure
#   Essentials 2-Day training course. This script automates environment
#   setup so learners can focus on learning Azure, not troubleshooting installs.
#
# SUPPORTED PLATFORMS:
#   - macOS (Intel & Apple Silicon) - Uses Homebrew
#   - Linux (Ubuntu/Debian) - Uses apt package manager
#   - WSL2 on Windows - Treated as Linux
#
# WHAT THIS SCRIPT INSTALLS:
#   1. Azure CLI (az)           - Primary CLI for managing Azure resources
#   2. Azure Developer CLI (azd)- Deployment orchestration for azd templates
#   3. Git                      - Version control for code and infrastructure
#   4. VS Code                  - Recommended IDE with Azure extensions
#   5. kubectl                  - Kubernetes cluster management CLI
#   6. Docker                   - Container runtime (manual install guided)
#   7. Python 3                 - Required for Azure Functions and scripts
#   8. jq                       - JSON processor for parsing Azure CLI output
#   9. Bicep CLI                - Azure's domain-specific language for IaC
#
# LEARNING CONCEPTS:
#   - Package managers (Homebrew, apt) automate software installation
#   - Infrastructure as Code (IaC) tools like Bicep define cloud resources
#   - CLI tools enable automation and scripting of cloud operations
#   - Container tools (Docker, kubectl) are essential for modern cloud apps
#
# USAGE:
#   chmod +x setup-local-tools.sh
#   ./setup-local-tools.sh
#
# AFTER RUNNING:
#   1. Run: az login              # Authenticate with your Azure subscription
#   2. Run: azd auth login        # Authenticate azd with Azure
#   3. Run: ./validate-env.sh     # Verify all tools are ready
#
#===============================================================================

# Exit immediately on error (fail-fast for training clarity)
set -e

#===============================================================================
# TERMINAL COLORS - Visual feedback for learners
#===============================================================================
# ANSI escape codes provide colored output in terminal emulators.
# This helps learners quickly identify success (green), warnings (yellow),
# errors (red), and informational messages (blue) during installation.
RED='\033[0;31m'     # Errors and critical failures
GREEN='\033[0;32m'   # Success messages
YELLOW='\033[1;33m'  # Warnings and manual actions needed
BLUE='\033[0;34m'    # Section headers and info
CYAN='\033[0;36m'    # Detailed explanations
NC='\033[0m'         # No Color (reset to default)

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║           Azure Essentials - Environment Setup                          ║"
echo "║           Code to Cloud | www.codetocloud.io                            ║"
echo "╠══════════════════════════════════════════════════════════════════════════╣"
echo "║  This script installs development tools for Azure cloud development.    ║"
echo "║  Sit back and watch as we configure your environment!                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

#===============================================================================
# OPERATING SYSTEM DETECTION
#===============================================================================
# Different operating systems use different package managers:
#   - macOS uses Homebrew (brew) - A community package manager
#   - Debian/Ubuntu uses APT (apt-get) - Advanced Package Tool
#   - RedHat/CentOS uses DNF/YUM - Not fully supported in this script
#
# WHY THIS MATTERS:
#   Cloud development tools are cross-platform, but installation methods
#   differ. This script abstracts away those differences for you.
#===============================================================================
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
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│ SYSTEM DETECTION                                                        │${NC}"
echo -e "${CYAN}├─────────────────────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} Detected Operating System: ${YELLOW}${OS}${NC}"
if [[ "$OS" == "macos" ]]; then
    echo -e "${CYAN}│${NC} Package Manager: ${YELLOW}Homebrew${NC} (brew)"
else
    echo -e "${CYAN}│${NC} Package Manager: ${YELLOW}APT${NC} (apt-get)"
fi
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────┘${NC}"

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Check if a command exists in the system PATH
# This is used to determine if a tool is already installed
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#===============================================================================
# HOMEBREW INSTALLATION (macOS only)
#===============================================================================
# WHAT IS HOMEBREW?
#   Homebrew is the "missing package manager for macOS". It simplifies
#   installing command-line tools that Apple doesn't provide by default.
#
# WHY WE USE IT:
#   - Installs tools with a single command (brew install <package>)
#   - Manages dependencies automatically
#   - Keeps tools updated (brew upgrade)
#   - Works for GUI apps too (brew install --cask <app>)
#
# LEARN MORE: https://brew.sh
#===============================================================================
install_homebrew() {
    if ! command_exists brew; then
        echo ""
        echo -e "${BLUE}━━━ Installing Homebrew ━━━${NC}"
        echo -e "${CYAN}Homebrew is the package manager for macOS.${NC}"
        echo -e "${CYAN}It will be used to install Azure CLI, kubectl, and other tools.${NC}"
        echo ""
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}✓ Homebrew already installed${NC}"
    fi
}

#===============================================================================
# AZURE CLI INSTALLATION
#===============================================================================
# WHAT IS AZURE CLI?
#   Azure CLI (az) is Microsoft's cross-platform command-line tool for
#   managing Azure resources. It's the primary interface for:
#   - Creating and managing resource groups, VMs, storage, networks
#   - Deploying ARM templates and Bicep files
#   - Querying resource status and properties
#   - Automating cloud operations in scripts
#
# KEY COMMANDS YOU'LL LEARN:
#   az login                    - Authenticate with Azure
#   az group create             - Create a resource group
#   az deployment group create  - Deploy Bicep/ARM templates
#   az resource list            - List resources in a subscription
#
# LEARN MORE: https://learn.microsoft.com/cli/azure/
#===============================================================================
install_azure_cli() {
    echo ""
    echo -e "${BLUE}━━━ Azure CLI (az) ━━━${NC}"
    echo -e "${CYAN}The primary tool for managing Azure resources from the command line.${NC}"
    echo -e "${CYAN}Used for: deployments, resource management, and automation.${NC}"
    echo ""

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

#===============================================================================
# AZURE DEVELOPER CLI (azd) INSTALLATION
#===============================================================================
# WHAT IS AZD?
#   Azure Developer CLI (azd) is a higher-level tool designed for developers.
#   While 'az' manages individual resources, 'azd' manages entire applications:
#   - Deploys complete application stacks from templates
#   - Manages infrastructure AND application code together
#   - Provides a streamlined dev → deploy workflow
#   - Uses azure.yaml to define application structure
#
# HOW AZD DIFFERS FROM AZ:
#   az  = "Create a storage account"  (resource-level)
#   azd = "Deploy my entire app"      (application-level)
#
# KEY COMMANDS YOU'LL LEARN:
#   azd init       - Initialize a new azd project
#   azd provision  - Create Azure infrastructure (runs Bicep files)
#   azd deploy     - Deploy application code to Azure
#   azd up         - Provision + Deploy in one command
#   azd down       - Tear down all resources (cleanup)
#
# THIS COURSE USES AZD:
#   The azure.yaml file at the project root defines our lessons.
#   Each 'azd up' deploys infrastructure defined in /infra/*.bicep files.
#
# LEARN MORE: https://learn.microsoft.com/azure/developer/azure-developer-cli/
#===============================================================================
install_azd() {
    echo ""
    echo -e "${BLUE}━━━ Azure Developer CLI (azd) ━━━${NC}"
    echo -e "${CYAN}Orchestrates full application deployments using Bicep templates.${NC}"
    echo -e "${CYAN}Used for: azd up (deploy), azd down (cleanup), azd provision.${NC}"
    echo ""

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

#===============================================================================
# KUBECTL INSTALLATION
#===============================================================================
# WHAT IS KUBECTL?
#   kubectl (pronounced "cube-control" or "cube-C-T-L") is the command-line
#   tool for managing Kubernetes clusters. Kubernetes is the industry standard
#   for container orchestration.
#
# WHY KUBERNETES MATTERS:
#   - Automates deployment, scaling, and management of containers
#   - Used by Azure Kubernetes Service (AKS)
#   - Declarative configuration (you define desired state)
#   - Self-healing (restarts failed containers automatically)
#
# KEY COMMANDS YOU'LL LEARN:
#   kubectl get pods              - List running containers
#   kubectl apply -f deploy.yaml  - Deploy from configuration
#   kubectl logs <pod>            - View container logs
#   kubectl exec -it <pod> -- sh  - Shell into a container
#
# USED IN: Lesson 06 (Linux/Kubernetes) and Lesson 07 (Container Services)
#
# LEARN MORE: https://kubernetes.io/docs/reference/kubectl/
#===============================================================================
install_kubectl() {
    echo ""
    echo -e "${BLUE}━━━ kubectl (Kubernetes CLI) ━━━${NC}"
    echo -e "${CYAN}Manages Kubernetes clusters and containerized applications.${NC}"
    echo -e "${CYAN}Used for: deploying containers, viewing logs, scaling apps.${NC}"
    echo ""

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

#===============================================================================
# DOCKER INSTALLATION
#===============================================================================
# WHAT IS DOCKER?
#   Docker is a platform for building, running, and sharing containers.
#   Containers package applications with all dependencies, ensuring they
#   run the same everywhere (your laptop, Azure, any cloud).
#
# KEY CONCEPTS:
#   - Image: A read-only template (like a class in programming)
#   - Container: A running instance of an image (like an object)
#   - Dockerfile: Instructions to build an image
#   - Registry: Storage for images (Docker Hub, Azure Container Registry)
#
# WHY CONTAINERS MATTER IN AZURE:
#   - Azure Container Instances (ACI) - Run containers without managing servers
#   - Azure Kubernetes Service (AKS) - Orchestrate many containers
#   - Azure Container Registry (ACR) - Store your container images
#   - Azure Container Apps - Serverless container platform
#
# USED IN: Lesson 07 (Container Services)
#
# NOTE: Docker Desktop requires manual installation due to licensing.
#
# LEARN MORE: https://docs.docker.com/get-started/
#===============================================================================
install_docker() {
    echo ""
    echo -e "${BLUE}━━━ Docker ━━━${NC}"
    echo -e "${CYAN}Build and run containers locally before deploying to Azure.${NC}"
    echo -e "${CYAN}Used for: building images, testing containers, pushing to ACR.${NC}"
    echo ""

    if ! command_exists docker; then
        echo -e "${YELLOW}Docker not found.${NC}"
        echo -e "${YELLOW}Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/${NC}"
        echo -e "${CYAN}  → Docker Desktop includes Docker Engine, CLI, and Docker Compose${NC}"
        echo -e "${CYAN}  → Required for Lesson 07: Container Services${NC}"
    else
        echo -e "${GREEN}✓ Docker already installed ($(docker version --format '{{.Client.Version}}' 2>/dev/null || echo 'installed'))${NC}"
    fi
}

#===============================================================================
# GIT INSTALLATION
#===============================================================================
# WHAT IS GIT?
#   Git is a distributed version control system. It tracks changes to files
#   and enables collaboration on code (and infrastructure!) projects.
#
# WHY GIT MATTERS FOR AZURE:
#   - Infrastructure as Code files (Bicep, ARM) should be version controlled
#   - Azure DevOps and GitHub integrate with Git for CI/CD pipelines
#   - Git enables GitOps workflows (infrastructure changes via pull requests)
#   - Clone this repository to get all course materials
#
# KEY COMMANDS:
#   git clone <url>     - Download a repository
#   git pull            - Get latest changes
#   git status          - See what's changed
#   git commit -m "..." - Save changes locally
#
# LEARN MORE: https://git-scm.com/doc
#===============================================================================
install_git() {
    echo ""
    echo -e "${BLUE}━━━ Git ━━━${NC}"
    echo -e "${CYAN}Version control for code and Infrastructure as Code files.${NC}"
    echo ""

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

#===============================================================================
# PYTHON INSTALLATION
#===============================================================================
# WHAT IS PYTHON?
#   Python is a versatile programming language widely used in cloud computing.
#   Azure has first-class Python support across many services.
#
# WHY PYTHON FOR AZURE:
#   - Azure Functions supports Python runtime
#   - Azure SDK for Python - programmatic resource management
#   - AI/ML services (Azure OpenAI, Cognitive Services) have Python SDKs
#   - Automation scripts and data processing
#
# USED IN:
#   - Lesson 08: Serverless (Azure Functions with Python)
#   - Lesson 09: Database Services (CosmosDB with Python SDK)
#   - Lesson 11: AI Foundry (Azure OpenAI with Python)
#
# LEARN MORE: https://learn.microsoft.com/azure/developer/python/
#===============================================================================
install_python() {
    echo ""
    echo -e "${BLUE}━━━ Python 3 ━━━${NC}"
    echo -e "${CYAN}Required for Azure Functions, Azure SDK, and AI services.${NC}"
    echo ""

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

#===============================================================================
# JQ INSTALLATION (JSON PROCESSOR)
#===============================================================================
# WHAT IS JQ?
#   jq is a lightweight command-line JSON processor. It's like 'sed' for JSON.
#   Essential for parsing Azure CLI output in automation scripts.
#
# WHY JQ MATTERS:
#   - Azure CLI returns JSON by default
#   - jq extracts specific values from complex JSON responses
#   - Enables powerful scripting and automation
#
# EXAMPLE USAGE:
#   # Get just the subscription ID from az account show
#   az account show | jq -r '.id'
#
#   # List all VM names in a resource group
#   az vm list -g myRG | jq -r '.[].name'
#
# LEARN MORE: https://stedolan.github.io/jq/tutorial/
#===============================================================================
install_jq() {
    echo ""
    echo -e "${BLUE}━━━ jq (JSON Processor) ━━━${NC}"
    echo -e "${CYAN}Parses JSON output from Azure CLI for scripting.${NC}"
    echo ""

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

#===============================================================================
# BICEP CLI INSTALLATION
#===============================================================================
# WHAT IS BICEP?
#   Bicep is Azure's domain-specific language (DSL) for deploying Azure
#   resources. It's a cleaner, more readable alternative to ARM JSON templates.
#
# WHY BICEP MATTERS (KEY CONCEPT!):
#   - Infrastructure as Code (IaC): Define cloud resources in code files
#   - Version controlled: Track infrastructure changes in Git
#   - Repeatable: Deploy the same infrastructure consistently
#   - Parameterized: Customize deployments for different environments
#
# BICEP VS ARM TEMPLATES:
#   - Bicep: param location string = 'eastus'
#   - ARM:   "parameters": { "location": { "type": "string", "defaultValue": "eastus" } }
#   Bicep compiles to ARM JSON, but is much easier to read and write!
#
# HOW WE USE BICEP IN THIS COURSE:
#   - /infra/main.bicep        - Entry point, orchestrates all modules
#   - /infra/modules/*.bicep   - Individual resource definitions
#   - azd provision            - Deploys Bicep files to Azure
#
# KEY BICEP CONCEPTS:
#   resource   - Defines an Azure resource
#   param      - Input parameter (customizable)
#   var        - Local variable
#   module     - Reusable Bicep file
#   output     - Values returned after deployment
#
# LEARN MORE: https://learn.microsoft.com/azure/azure-resource-manager/bicep/
#===============================================================================
echo ""
echo -e "${BLUE}━━━ Bicep CLI ━━━${NC}"
echo -e "${CYAN}Azure's Infrastructure as Code language (compiles to ARM templates).${NC}"
echo -e "${CYAN}Used for: defining Azure resources in .bicep files.${NC}"
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
