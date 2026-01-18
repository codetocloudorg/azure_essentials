#!/bin/bash
#===============================================================================
# Lesson 07: Container Services - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create Azure Container Registry
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#
# Usage:
#   ./lesson-07-containers.sh
#   ./lesson-07-containers.sh --cleanup
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
LOCATION="${LOCATION:-centralus}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-containers}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
ACR_NAME="acressentials${UNIQUE_SUFFIX}"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 07: Container Services${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

#===============================================================================
# Cleanup Function
#===============================================================================

cleanup() {
    print_header
    echo "Cleaning up container resources..."
    echo ""

    print_step "Deleting resource group: ${RESOURCE_GROUP}"
    az group delete \
        --name "$RESOURCE_GROUP" \
        --yes \
        --no-wait

    echo ""
    echo -e "${GREEN}✓ Cleanup initiated (runs in background)${NC}"
}

#===============================================================================
# Deploy Function
#===============================================================================

deploy() {
    print_header

    print_info "Location: ${LOCATION}"
    print_info "Resource Group: ${RESOURCE_GROUP}"
    print_info "Container Registry: ${ACR_NAME}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=07-containers"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Container Registry
    #---------------------------------------------------------------------------
    print_step "Creating Azure Container Registry: ${ACR_NAME}"

    az acr create \
        --name "$ACR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Basic \
        --admin-enabled true

    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Get Login Credentials
    #---------------------------------------------------------------------------
    print_step "Retrieving login credentials..."

    local login_server=$(az acr show \
        --name "$ACR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query loginServer \
        -o tsv)

    local admin_user=$(az acr credential show \
        --name "$ACR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query username \
        -o tsv)

    local admin_pass=$(az acr credential show \
        --name "$ACR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "passwords[0].value" \
        -o tsv)

    echo "  ✓ Credentials retrieved"
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Show Registry Details
    #---------------------------------------------------------------------------
    print_step "Container Registry details:"

    az acr show \
        --name "$ACR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "{Name:name, LoginServer:loginServer, SKU:sku.name, AdminEnabled:adminUserEnabled}" \
        -o table

    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Azure Container Registry:${NC}"
    echo "  Name:         ${ACR_NAME}"
    echo "  Login Server: ${login_server}"
    echo "  SKU:          Basic"
    echo "  Admin User:   ${admin_user}"
    echo "  Admin Pass:   ${admin_pass:0:8}..."
    echo ""
    echo -e "${CYAN}Docker Commands:${NC}"
    echo ""
    echo "  # Login to ACR"
    echo "  docker login ${login_server} -u ${admin_user} -p '${admin_pass}'"
    echo ""
    echo "  # Or use Azure CLI login"
    echo "  az acr login --name ${ACR_NAME}"
    echo ""
    echo "  # Tag and push an image"
    echo "  docker tag myapp:latest ${login_server}/myapp:v1"
    echo "  docker push ${login_server}/myapp:v1"
    echo ""
    echo "  # List images in registry"
    echo "  az acr repository list --name ${ACR_NAME} -o table"
    echo ""
    echo "Resource Group: ${RESOURCE_GROUP}"
    echo ""
    echo "Cleanup:"
    echo "  $0 --cleanup"
    echo ""
}

#===============================================================================
# Key Commands Reference
#===============================================================================

show_commands() {
    echo ""
    echo -e "${CYAN}Key Azure CLI Commands for Containers:${NC}"
    echo ""
    echo "# Create container registry"
    echo "az acr create --name <acr> --resource-group <rg> --sku Basic --admin-enabled true"
    echo ""
    echo "# Login to ACR"
    echo "az acr login --name <acr>"
    echo ""
    echo "# Get login server"
    echo "az acr show --name <acr> --query loginServer -o tsv"
    echo ""
    echo "# Get admin credentials"
    echo "az acr credential show --name <acr>"
    echo ""
    echo "# List repositories"
    echo "az acr repository list --name <acr> -o table"
    echo ""
    echo "# Show image tags"
    echo "az acr repository show-tags --name <acr> --repository <repo>"
    echo ""
    echo "# Build image in ACR"
    echo "az acr build --registry <acr> --image myapp:v1 ."
    echo ""
    echo "# Import image to ACR"
    echo "az acr import --name <acr> --source docker.io/library/nginx:latest --image nginx:latest"
    echo ""
}

#===============================================================================
# Main
#===============================================================================

case "${1:-}" in
    --cleanup|-c)
        cleanup
        ;;
    --commands|-h)
        show_commands
        ;;
    *)
        deploy
        ;;
esac
