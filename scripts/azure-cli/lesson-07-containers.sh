#!/bin/bash
#===============================================================================
# Lesson 07: Container Services - Build → Push → AKS Overview
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# This script demonstrates the complete container workflow:
#   1. Create Azure Container Registry (ACR)
#   2. Build a container image in ACR
#   3. Show how to deploy to AKS (overview)
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#
# Usage:
#   ./lesson-07-containers.sh              # Deploy ACR + build container
#   ./lesson-07-containers.sh --cleanup    # Delete all resources
#   ./lesson-07-containers.sh --commands   # Show key commands
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
LOCATION="${LOCATION:-centralus}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-containers}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
ACR_NAME="acressentials${UNIQUE_SUFFIX}"

# Get script directory for finding sample app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HELLO_APP_DIR="${REPO_ROOT}/lessons/07-container-services/src/hello-container"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 07: Container Services${NC}"
    echo -e "${CYAN}  Build → Push to ACR → AKS Overview${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
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
    echo ""
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
        --tags "course=azure-essentials" "lesson=07-containers" \
        --output none

    print_success "Resource group created"
    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Container Registry
    #---------------------------------------------------------------------------
    print_step "Creating Azure Container Registry: ${ACR_NAME}"
    print_info "This takes about 30 seconds..."

    az acr create \
        --name "$ACR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Basic \
        --admin-enabled true \
        --output none

    print_success "Container Registry created"
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

    print_success "Credentials retrieved"
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Build Hello Container in ACR
    #---------------------------------------------------------------------------
    print_step "Building hello-container image in ACR..."
    print_info "This builds the container IN AZURE (no local Docker needed!)"
    echo ""

    if [[ -d "$HELLO_APP_DIR" ]]; then
        az acr build \
            --registry "$ACR_NAME" \
            --image hello-container:v1 \
            --file "${HELLO_APP_DIR}/Dockerfile" \
            "$HELLO_APP_DIR" \
            --no-logs

        print_success "Image built: ${login_server}/hello-container:v1"
    else
        echo -e "${YELLOW}  ⚠ Sample app not found at ${HELLO_APP_DIR}${NC}"
        echo "  Skipping container build..."
    fi
    echo ""

    #---------------------------------------------------------------------------
    # Step 5: List Images in Registry
    #---------------------------------------------------------------------------
    print_step "Listing images in registry..."

    az acr repository list --name "$ACR_NAME" -o table 2>/dev/null || echo "  (No images yet)"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Show AKS Overview (Don't create - just explain)
    #---------------------------------------------------------------------------
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  AKS (Azure Kubernetes Service) Overview${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  AKS is Azure's managed Kubernetes service:"
    echo ""
    echo "  What You Pay For:              What Azure Manages:"
    echo "  - Worker node VMs              - Control plane (FREE)"
    echo "  - Storage for containers       - API server"
    echo "  - Network egress               - etcd cluster + Upgrades"
    echo ""
    echo "  Container Workflow:"
    echo ""
    echo "  Dockerfile --> az acr build --> kubectl apply"
    echo "       |              |                |"
    echo "    Build         Push to ACR     Deploy to AKS"
    echo ""
    echo "  To create AKS cluster (not in this lesson due to cost):"
    echo ""
    echo "  # Create AKS cluster (~\$70/month for 1 node)"
    echo "  az aks create --name myaks --resource-group \$RG --node-count 1"
    echo ""
    echo "  # Attach ACR to AKS (allows pulling images)"
    echo "  az aks update --name myaks --resource-group \$RG --attach-acr ${ACR_NAME}"
    echo ""
    echo "  # Get kubectl credentials"
    echo "  az aks get-credentials --name myaks --resource-group \$RG"
    echo ""
    echo "  # Deploy your container"
    echo "  kubectl create deployment hello --image=${login_server}/hello-container:v1"
    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Azure Container Registry:${NC}"
    echo "  Name:         ${ACR_NAME}"
    echo "  Login Server: ${login_server}"
    echo "  SKU:          Basic (~\$5/month)"
    echo ""
    echo -e "${CYAN}Container Image Built:${NC}"
    echo "  ${login_server}/hello-container:v1"
    echo ""
    echo -e "${CYAN}Try These Commands:${NC}"
    echo ""
    echo "  # List images"
    echo "  az acr repository list --name ${ACR_NAME} -o table"
    echo ""
    echo "  # Show image tags"
    echo "  az acr repository show-tags --name ${ACR_NAME} --repository hello-container"
    echo ""
    echo "  # Run locally with Docker (if installed)"
    echo "  az acr login --name ${ACR_NAME}"
    echo "  docker run -p 8080:8080 ${login_server}/hello-container:v1"
    echo "  # Open http://localhost:8080"
    echo ""
    echo "Resource Group: ${RESOURCE_GROUP}"
    echo ""
    echo "Cleanup:"
    echo "  \$0 --cleanup"
    echo ""
}

#===============================================================================
# Key Commands Reference
#===============================================================================

show_commands() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Container Commands Cheat Sheet${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Azure Container Registry (ACR)${NC}"
    echo ""
    echo "# Create registry"
    echo "az acr create --name <acr> --resource-group <rg> --sku Basic --admin-enabled true"
    echo ""
    echo "# Login to ACR"
    echo "az acr login --name <acr>"
    echo ""
    echo "# Build image IN AZURE (no local Docker needed!)"
    echo "az acr build --registry <acr> --image myapp:v1 ."
    echo ""
    echo "# List repositories"
    echo "az acr repository list --name <acr> -o table"
    echo ""
    echo "# Import public image to ACR"
    echo "az acr import --name <acr> --source docker.io/nginx:latest --image nginx:v1"
    echo ""
    echo -e "${YELLOW}Azure Kubernetes Service (AKS)${NC}"
    echo ""
    echo "# Create AKS cluster"
    echo "az aks create --name <aks> --resource-group <rg> --node-count 1 --generate-ssh-keys"
    echo ""
    echo "# Attach ACR to AKS"
    echo "az aks update --name <aks> --resource-group <rg> --attach-acr <acr>"
    echo ""
    echo "# Get kubectl credentials"
    echo "az aks get-credentials --name <aks> --resource-group <rg>"
    echo ""
    echo "# Deploy container"
    echo "kubectl create deployment myapp --image=<acr>.azurecr.io/myapp:v1"
    echo ""
    echo "# Expose as service"
    echo "kubectl expose deployment myapp --type=LoadBalancer --port=80 --target-port=8080"
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
