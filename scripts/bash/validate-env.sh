#!/bin/bash
#===============================================================================
# Azure Essentials - Environment Validation Script
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# PURPOSE:
#   Validates that all required tools are properly installed and configured
#   before starting the Azure Essentials course. Running this script ensures
#   you won't encounter tool-related issues during lessons.
#
# WHAT THIS SCRIPT CHECKS:
#   1. Required CLI Tools
#      - Azure CLI (az)     - Manages Azure resources
#      - Azure Developer CLI (azd) - Deploys applications
#      - Git                - Version control
#      - Python 3           - For Azure Functions and SDKs
#      - kubectl            - Kubernetes management
#      - jq                  - JSON parsing
#      - Bicep CLI          - Infrastructure as Code compiler
#
#   2. Authentication Status
#      - Azure CLI login    - Connected to your subscription?
#      - azd login          - Authenticated for deployments?
#
#   3. Container Environment
#      - Docker daemon      - Is Docker Desktop running?
#
#   4. Development Environment (Optional)
#      - VS Code extensions - Recommended extensions installed?
#
#   5. Azure Subscription
#      - Resource providers - Are required providers registered?
#
# WHY VALIDATION MATTERS:
#   - Catch setup issues BEFORE they interrupt learning
#   - Ensure consistent environment across all learners
#   - Verify Azure access and permissions
#
# USAGE:
#   ./scripts/bash/validate-env.sh
#
# OUTPUT LEGEND:
#   ✓ = Passed (green)    - All good!
#   ✗ = Failed (red)      - Action required
#   ⚠ = Warning (yellow)  - Optional but recommended
#
#===============================================================================

# Don't exit on error - we want to run all checks and report at the end
# set -e

#===============================================================================
# TERMINAL COLORS - Visual feedback for quick scanning
#===============================================================================
# Color-coding helps quickly identify issues during validation:
#   RED    = Action required (something is missing or broken)
#   GREEN  = All good (tool installed and working)
#   YELLOW = Warning (works, but could be improved)
#   BLUE   = Section headers and informational
RED='\033[0;31m'      # Errors requiring action
GREEN='\033[0;32m'    # Success - no action needed
YELLOW='\033[1;33m'   # Warnings - optional improvements
BLUE='\033[0;34m'     # Section headers
CYAN='\033[0;36m'     # Explanatory text
NC='\033[0m'          # No Color (reset)

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║           Azure Essentials - Environment Check                          ║"
echo "║           Code to Cloud | www.codetocloud.io                            ║"
echo "╠══════════════════════════════════════════════════════════════════════════╣"
echo "║  Validating your development environment for Azure development.        ║"
echo "║  This checks tools, authentication, and Azure subscription access.     ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

#===============================================================================
# VALIDATION STATE TRACKING
#===============================================================================
# We track overall validation status. If ANY required check fails,
# VALIDATION_PASSED becomes false and we'll alert at the end.
VALIDATION_PASSED=true

#===============================================================================
# TOOL VALIDATION FUNCTION
#===============================================================================
# This function checks if a command-line tool exists and reports its version.
# It's a reusable pattern you'll see in many DevOps scripts.
#
# Parameters:
#   $1 = Tool name (e.g., "az", "azd", "kubectl")
#   $2 = Minimum version (for reference, not strictly enforced)
#   $3 = Installation URL (shown if tool is missing)
#
# The function uses 'command -v' to check if a tool is in PATH.
# This is more portable than 'which' across different systems.
#===============================================================================
check_tool() {
    local tool=$1
    local min_version=$2
    local install_url=$3

    if command -v "$tool" >/dev/null 2>&1; then
        local version=$($tool --version 2>/dev/null | head -1 || echo "installed")
        echo -e "${GREEN}✓ $tool${NC} - $version"
        return 0
    else
        echo -e "${RED}✗ $tool not found${NC}"
        echo -e "  ${CYAN}Why needed:${NC} Required for Azure development"
        echo -e "  ${CYAN}Install:${NC} $install_url"
        VALIDATION_PASSED=false
        return 1
    fi
}

#===============================================================================
# AZURE CLI AUTHENTICATION CHECK
#===============================================================================
# WHY AUTHENTICATION MATTERS:
#   Azure CLI must be authenticated to manage your Azure subscription.
#   The 'az login' command opens a browser for Microsoft account login.
#
# WHAT WE CHECK:
#   - 'az account show' returns current subscription info if logged in
#   - If not logged in, it returns an error
#
# AUTHENTICATION TYPES:
#   - Interactive: az login (browser-based, used in training)
#   - Service Principal: az login --service-principal (for automation)
#   - Managed Identity: Automatic in Azure VMs/Functions
#
# SUBSCRIPTION CONTEXT:
#   After login, Azure CLI uses a "default" subscription. You can change it:
#   az account set --subscription "<subscription-name-or-id>"
#===============================================================================
check_azure_login() {
    echo ""
    echo -e "${BLUE}━━━ Azure CLI Authentication ━━━${NC}"
    echo -e "${CYAN}Checking if you're logged into Azure...${NC}"

    if az account show >/dev/null 2>&1; then
        local account=$(az account show --query name -o tsv)
        local sub_id=$(az account show --query id -o tsv)
        echo -e "${GREEN}✓ Azure CLI authenticated${NC}"
        echo -e "  ${CYAN}Subscription:${NC} $account"
        echo -e "  ${CYAN}ID:${NC} ${sub_id:0:8}..."
        echo -e "  ${CYAN}Tip:${NC} Use 'az account list' to see all subscriptions"
    else
        echo -e "${YELLOW}⚠ Azure CLI not authenticated${NC}"
        echo -e "  ${CYAN}Why needed:${NC} Required to create and manage Azure resources"
        echo -e "  ${CYAN}Fix:${NC} Run 'az login' to authenticate"
        VALIDATION_PASSED=false
    fi
}

#===============================================================================
# AZURE DEVELOPER CLI (azd) AUTHENTICATION CHECK
#===============================================================================
# WHY SEPARATE LOGIN?
#   azd has its own authentication separate from Azure CLI.
#   This allows azd to use different credentials for deployments.
#
# HOW AZD USES AUTHENTICATION:
#   - 'azd provision' needs auth to create Azure resources
#   - 'azd deploy' needs auth to push code/containers to Azure
#   - azd stores credentials securely in your system keychain
#===============================================================================
check_azd_login() {
    echo ""
    echo -e "${BLUE}━━━ Azure Developer CLI Authentication ━━━${NC}"
    echo -e "${CYAN}Checking azd authentication status...${NC}"

    if azd auth login --check-status >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Azure Developer CLI authenticated${NC}"
        echo -e "  ${CYAN}Ready for:${NC} azd init, azd provision, azd deploy, azd up"
    else
        echo -e "${YELLOW}⚠ Azure Developer CLI not authenticated${NC}"
        echo -e "  ${CYAN}Why needed:${NC} Required for 'azd up' deployments"
        echo -e "  ${CYAN}Fix:${NC} Run 'azd auth login'"
        VALIDATION_PASSED=false
    fi
}

#===============================================================================
# DOCKER DAEMON CHECK
#===============================================================================
# WHAT IS THE DOCKER DAEMON?
#   Docker runs as a background service (daemon) that manages containers.
#   Docker Desktop starts this daemon automatically on macOS/Windows.
#
# WHY THIS CHECK:
#   - Docker CLI is installed, but daemon might not be running
#   - Container builds will fail without a running daemon
#   - Required for Lesson 07: Container Services
#
# COMMON ISSUES:
#   - Docker Desktop not started after reboot
#   - Docker Desktop subscription/licensing on corporate machines
#   - Resource limits (CPU/memory) in Docker Desktop settings
#===============================================================================
check_docker_running() {
    echo ""
    echo -e "${BLUE}━━━ Docker Container Runtime ━━━${NC}"
    echo -e "${CYAN}Checking if Docker is installed and daemon is running...${NC}"

    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Docker daemon running${NC}"
            local docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
            echo -e "  ${CYAN}Version:${NC} $docker_version"
            echo -e "  ${CYAN}Ready for:${NC} Building images, running containers"
        else
            echo -e "${YELLOW}⚠ Docker installed but daemon not running${NC}"
            echo -e "  ${CYAN}Why needed:${NC} Required for container builds in Lesson 07"
            echo -e "  ${CYAN}Fix:${NC} Start Docker Desktop or run 'sudo systemctl start docker'"
        fi
    else
        echo -e "${RED}✗ Docker not installed${NC}"
        echo -e "  ${CYAN}Why needed:${NC} Required for Container Services lesson"
        echo -e "  ${CYAN}Install:${NC} https://www.docker.com/products/docker-desktop/"
        VALIDATION_PASSED=false
    fi
}

#===============================================================================
# VS CODE EXTENSIONS CHECK (OPTIONAL)
#===============================================================================
# WHY VS CODE EXTENSIONS MATTER:
#   Extensions add language support, debugging, and tooling to VS Code.
#   These extensions enhance the Azure development experience.
#
# RECOMMENDED EXTENSIONS:
#   - ms-azuretools.vscode-bicep      - Bicep syntax highlighting & validation
#   - ms-vscode.vscode-node-azure-pack - Azure services integration
#   - ms-kubernetes-tools.vscode-kubernetes-tools - K8s cluster management
#   - redhat.vscode-yaml              - YAML syntax for K8s manifests
#
# BENEFITS:
#   - IntelliSense for Bicep files (autocomplete Azure resource types)
#   - Direct Azure resource browsing in VS Code sidebar
#   - Kubernetes cluster visualization and management
#===============================================================================
check_vscode_extensions() {
    echo ""
    echo -e "${BLUE}━━━ VS Code Extensions (Optional) ━━━${NC}"
    echo -e "${CYAN}Checking recommended extensions for Azure development...${NC}"

    if command -v code >/dev/null 2>&1; then
        local extensions=(
            "ms-azuretools.vscode-bicep"                     # Bicep language support
            "ms-vscode.vscode-node-azure-pack"               # Azure tools bundle
            "ms-kubernetes-tools.vscode-kubernetes-tools"
            "redhat.vscode-yaml"
        )

        local installed_extensions=$(code --list-extensions 2>/dev/null)

        for ext in "${extensions[@]}"; do
            if echo "$installed_extensions" | grep -q "$ext"; then
                echo -e "${GREEN}✓ $ext${NC}"
            else
                echo -e "${YELLOW}⚠ $ext not installed${NC}"
                echo -e "  Run: code --install-extension $ext"
            fi
        done
    else
        echo -e "${YELLOW}⚠ VS Code CLI not found (optional)${NC}"
    fi
}

#===============================================================================
# AZURE RESOURCE PROVIDERS CHECK
#===============================================================================
# WHAT ARE RESOURCE PROVIDERS?
#   Azure organizes services into "resource providers" (namespaces).
#   Each provider must be registered before you can create those resources.
#
# COMMON PROVIDERS:
#   - Microsoft.Compute   = VMs, VM Scale Sets, Disks
#   - Microsoft.Storage   = Storage Accounts, Blobs, Files
#   - Microsoft.Network   = VNets, Load Balancers, Public IPs
#   - Microsoft.Web       = App Services, Functions, Static Web Apps
#
# WHY THIS MATTERS:
#   - New subscriptions may not have all providers registered
#   - "ResourceProviderNotRegistered" errors during deployment
#   - Azure automatically registers some providers on first use
#
# MANUAL REGISTRATION:
#   az provider register --namespace Microsoft.Compute
#===============================================================================
check_azure_quotas() {
    echo ""
    echo -e "${BLUE}━━━ Azure Subscription & Resource Providers ━━━${NC}"
    echo -e "${CYAN}Verifying required Azure services are available...${NC}"

    if az account show >/dev/null 2>&1; then
        # Check if free tier
        local subscription_name=$(az account show --query name -o tsv)
        echo -e "  ${CYAN}Subscription:${NC} $subscription_name"
        echo ""

        # Check resource providers
        local providers=("Microsoft.Compute" "Microsoft.Storage" "Microsoft.Network" "Microsoft.Web")

        echo -e "  ${CYAN}Checking resource provider registration:${NC}"
        for provider in "${providers[@]}"; do
            local state=$(az provider show --namespace "$provider" --query registrationState -o tsv 2>/dev/null || echo "Unknown")
            if [[ "$state" == "Registered" ]]; then
                echo -e "${GREEN}  ✓ $provider${NC} - Ready"
            else
                echo -e "${YELLOW}  ⚠ $provider: $state${NC}"
                echo -e "    ${CYAN}Register with:${NC} az provider register --namespace $provider"
            fi
        done
    fi
}

#===============================================================================
# MAIN VALIDATION SEQUENCE
#===============================================================================
# We check tools in order of dependency:
#   1. Core tools first (az, azd, git) - needed for everything
#   2. Language runtimes (python) - needed for Functions/SDKs
#   3. Container tools (kubectl, docker) - needed for container lessons
#   4. Utility tools (jq) - helpful for scripting
#   5. IaC tools (Bicep) - needed for infrastructure deployment
#===============================================================================

echo ""
echo -e "${BLUE}━━━ Core Development Tools ━━━${NC}"
echo -e "${CYAN}These tools are required for all lessons:${NC}"
echo ""

check_tool "az" "2.50.0" "https://learn.microsoft.com/cli/azure/install-azure-cli"
check_tool "azd" "1.5.0" "https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd"
check_tool "git" "2.0.0" "https://git-scm.com/downloads"
check_tool "python3" "3.9.0" "https://www.python.org/downloads/"
check_tool "kubectl" "1.28.0" "https://kubernetes.io/docs/tasks/tools/"
check_tool "jq" "1.6" "https://stedolan.github.io/jq/download/"

#===============================================================================
# BICEP CLI CHECK
#===============================================================================
# Bicep is installed via Azure CLI, not as a standalone tool.
# 'az bicep version' checks if it's available.
#===============================================================================
echo ""
echo -e "${BLUE}━━━ Infrastructure as Code Tools ━━━${NC}"
echo -e "${CYAN}Bicep compiles to ARM templates for Azure deployments:${NC}"
echo ""
if az bicep version >/dev/null 2>&1; then
    bicep_version=$(az bicep version 2>&1 | head -1)
    echo -e "${GREEN}✓ Bicep CLI${NC} - $bicep_version"
    echo -e "  ${CYAN}Location:${NC} /infra/*.bicep files define our Azure infrastructure"
else
    echo -e "${YELLOW}⚠ Bicep CLI not installed${NC}"
    echo -e "  ${CYAN}Why needed:${NC} Compiles .bicep files to ARM templates for deployment"
    echo -e "  ${CYAN}Fix:${NC} Run 'az bicep install'"
fi

check_docker_running
check_azure_login
check_azd_login
check_vscode_extensions
check_azure_quotas

#===============================================================================
# VALIDATION SUMMARY
#===============================================================================
# Provides a clear summary of environment readiness and next steps.
#===============================================================================
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           VALIDATION SUMMARY                                            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if $VALIDATION_PASSED; then
    echo -e "${GREEN}✓ All checks passed! Your environment is ready.${NC}"
    echo ""
    echo -e "${BLUE}You're ready to start the Azure Essentials course!${NC}"
    echo ""
    echo -e "${CYAN}QUICK START:${NC}"
    echo "  1. cd azure_essentials"
    echo "  2. ./scripts/bash/deploy.sh    # Interactive deployment menu"
    echo ""
    echo -e "${CYAN}WHAT HAPPENS DURING DEPLOYMENT:${NC}"
    echo "  • azd reads azure.yaml to understand the project"
    echo "  • Bicep files in /infra define Azure resources"
    echo "  • Azure CLI creates resources in your subscription"
    echo "  • You can view resources in the Azure Portal"
else
    echo -e "${YELLOW}⚠ Some checks failed or have warnings.${NC}"
    echo ""
    echo -e "${CYAN}Please address the issues above before starting the course.${NC}"
    echo "Run this script again after making changes to verify fixes."
    echo ""
    echo -e "${CYAN}COMMON FIXES:${NC}"
    echo "  • Missing tools: Run ./scripts/bash/setup-local-tools.sh"
    echo "  • Not logged in: Run 'az login' and 'azd auth login'"
    echo "  • Docker not running: Start Docker Desktop"
fi

echo ""
