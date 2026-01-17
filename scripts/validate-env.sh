#!/bin/bash
# Azure Essentials - Environment Validation Script
# Code to Cloud
#
# This script validates that all required tools are installed and configured.

set -e

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

echo -e "${BLUE}"
echo "=========================================="
echo "  Azure Essentials - Environment Check   "
echo "  Code to Cloud                          "
echo "=========================================="
echo -e "${NC}"

# Track validation status
VALIDATION_PASSED=true

# Check if a command exists
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
        echo -e "  Install: $install_url"
        VALIDATION_PASSED=false
        return 1
    fi
}

# Check Azure CLI login status
check_azure_login() {
    echo ""
    echo -e "${BLUE}Checking Azure authentication...${NC}"
    
    if az account show >/dev/null 2>&1; then
        local account=$(az account show --query name -o tsv)
        local sub_id=$(az account show --query id -o tsv)
        echo -e "${GREEN}✓ Azure CLI authenticated${NC}"
        echo -e "  Subscription: $account"
        echo -e "  ID: ${sub_id:0:8}..."
    else
        echo -e "${YELLOW}⚠ Azure CLI not authenticated${NC}"
        echo -e "  Run: az login"
        VALIDATION_PASSED=false
    fi
}

# Check azd login status
check_azd_login() {
    if azd auth login --check-status >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Azure Developer CLI authenticated${NC}"
    else
        echo -e "${YELLOW}⚠ Azure Developer CLI not authenticated${NC}"
        echo -e "  Run: azd auth login"
        VALIDATION_PASSED=false
    fi
}

# Check Docker daemon
check_docker_running() {
    echo ""
    echo -e "${BLUE}Checking Docker...${NC}"
    
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Docker daemon running${NC}"
        else
            echo -e "${YELLOW}⚠ Docker installed but daemon not running${NC}"
            echo -e "  Start Docker Desktop or the Docker service"
        fi
    else
        echo -e "${RED}✗ Docker not installed${NC}"
        VALIDATION_PASSED=false
    fi
}

# Check VS Code extensions
check_vscode_extensions() {
    echo ""
    echo -e "${BLUE}Checking VS Code extensions...${NC}"
    
    if command -v code >/dev/null 2>&1; then
        local extensions=(
            "ms-azuretools.vscode-bicep"
            "ms-vscode.vscode-node-azure-pack"
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

# Check Azure subscription quotas
check_azure_quotas() {
    echo ""
    echo -e "${BLUE}Checking Azure subscription...${NC}"
    
    if az account show >/dev/null 2>&1; then
        # Check if free tier
        local subscription_name=$(az account show --query name -o tsv)
        echo -e "  Subscription: $subscription_name"
        
        # Check resource providers
        local providers=("Microsoft.Compute" "Microsoft.Storage" "Microsoft.Network" "Microsoft.Web")
        
        for provider in "${providers[@]}"; do
            local state=$(az provider show --namespace "$provider" --query registrationState -o tsv 2>/dev/null || echo "Unknown")
            if [[ "$state" == "Registered" ]]; then
                echo -e "${GREEN}  ✓ $provider registered${NC}"
            else
                echo -e "${YELLOW}  ⚠ $provider: $state${NC}"
            fi
        done
    fi
}

# Main validation
echo ""
echo -e "${BLUE}Checking required tools...${NC}"
echo ""

check_tool "az" "2.50.0" "https://learn.microsoft.com/cli/azure/install-azure-cli"
check_tool "azd" "1.5.0" "https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd"
check_tool "git" "2.0.0" "https://git-scm.com/downloads"
check_tool "python3" "3.9.0" "https://www.python.org/downloads/"
check_tool "kubectl" "1.28.0" "https://kubernetes.io/docs/tasks/tools/"
check_tool "jq" "1.6" "https://stedolan.github.io/jq/download/"

# Check Bicep
echo ""
if az bicep version >/dev/null 2>&1; then
    local bicep_version=$(az bicep version 2>&1 | head -1)
    echo -e "${GREEN}✓ Bicep CLI${NC} - $bicep_version"
else
    echo -e "${YELLOW}⚠ Bicep CLI not installed${NC}"
    echo -e "  Run: az bicep install"
fi

check_docker_running
check_azure_login
check_azd_login
check_vscode_extensions
check_azure_quotas

# Summary
echo ""
echo -e "${BLUE}=========================================="
echo "  Validation Summary"
echo "==========================================${NC}"
echo ""

if $VALIDATION_PASSED; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo -e "${BLUE}You're ready to start the course.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. cd azure_essentials"
    echo "  2. azd init"
    echo "  3. azd up"
else
    echo -e "${YELLOW}⚠ Some checks failed or have warnings.${NC}"
    echo ""
    echo "Please address the issues above before starting the course."
    echo "Run this script again after making changes."
fi

echo ""
