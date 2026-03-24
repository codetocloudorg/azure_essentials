#!/bin/bash
#===============================================================================
# Lesson 07: Container Services - ACR + Container Apps + Hello World
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# This script demonstrates the complete container workflow:
#   1. Create Azure Container Registry (ACR)
#   2. Build a container image in ACR
#   3. Create Azure Container Apps environment
#   4. Deploy hello-container to Container Apps
#
# COST ESTIMATE:
#   ACR Basic:  ~$5/month
#   Container Apps: ~$0 at low traffic (consumption plan)
#   Total: ~$5/month
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#
# Usage:
#   ./lesson-07-containers.sh              # Deploy ACR + Container Apps + app
#   ./lesson-07-containers.sh --yes        # Deploy without confirmation prompt
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
CAE_NAME="cae-essentials-${UNIQUE_SUFFIX}"
CA_NAME="hello-${UNIQUE_SUFFIX}"
SKIP_CONFIRM="${SKIP_CONFIRM:-false}"

# Get script directory for finding sample app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HELLO_APP_DIR="${REPO_ROOT}/lessons/07-container-services/src/hello-container"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 07: Container Services${NC}"
    echo -e "${CYAN}  ACR + Container Apps + Hello World Deployment${NC}"
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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
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
    print_info "Container Apps Environment: ${CAE_NAME}"
    echo ""

    if [[ "$SKIP_CONFIRM" != "true" ]]; then
        print_warning "This will create ACR + Container Apps (~\$5/month). Continue? (y/n)"
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "Deployment cancelled."
            exit 0
        fi
    else
        print_info "Skipping confirmation (--yes flag)"
    fi
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

    local login_server=$(az acr show \
        --name "$ACR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query loginServer \
        -o tsv)

    print_success "Container Registry created: ${login_server}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Build Hello Container in ACR
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
        echo "  Creating a simple nginx deployment instead..."
    fi
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Install Container Apps extension
    #---------------------------------------------------------------------------
    print_step "Installing Container Apps extension..."
    az extension add --name containerapp --upgrade -y 2>/dev/null
    print_success "Extension ready"
    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Create Container Apps Environment
    #---------------------------------------------------------------------------
    print_step "Creating Container Apps Environment: ${CAE_NAME}"
    print_info "This takes 1-2 minutes..."
    echo ""

    az containerapp env create \
        --name "$CAE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --output none

    print_success "Container Apps Environment created"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Deploy Hello Container to Container Apps
    #---------------------------------------------------------------------------
    print_step "Deploying hello-container to Container Apps..."

    az containerapp create \
        --name "$CA_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --environment "$CAE_NAME" \
        --image "${login_server}/hello-container:v1" \
        --registry-server "$login_server" \
        --registry-username "$(az acr credential show -n "$ACR_NAME" --query username -o tsv)" \
        --registry-password "$(az acr credential show -n "$ACR_NAME" --query passwords[0].value -o tsv)" \
        --target-port 8080 \
        --ingress external \
        --output none

    print_success "Container App deployed"
    echo ""

    #---------------------------------------------------------------------------
    # Step 7: Get App URL
    #---------------------------------------------------------------------------
    local app_fqdn=$(az containerapp show \
        --name "$CA_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query properties.configuration.ingress.fqdn \
        -o tsv)

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Deployment Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Azure Container Registry:${NC}"
    echo "  Name:         ${ACR_NAME}"
    echo "  Login Server: ${login_server}"
    echo "  SKU:          Basic (~\$5/month)"
    echo ""
    echo -e "${CYAN}Azure Container Apps:${NC}"
    echo "  Environment:  ${CAE_NAME}"
    echo "  App:          ${CA_NAME}"
    echo "  Cost:         ~\$0 at low traffic (consumption plan)"
    echo ""
    echo -e "${CYAN}Hello Container App:${NC}"
    if [[ -n "$app_fqdn" ]]; then
        echo "  URL:          https://${app_fqdn}"
        echo ""
        echo -e "${YELLOW}🌐 Open in browser: ${BOLD}https://${app_fqdn}${NC}"
    else
        echo "  URL:          (check: az containerapp show -n ${CA_NAME} -g ${RESOURCE_GROUP} --query properties.configuration.ingress.fqdn)"
    fi
    echo ""
    echo -e "${CYAN}Useful Commands:${NC}"
    echo ""
    echo "  # Check app status"
    echo "  az containerapp show -n ${CA_NAME} -g ${RESOURCE_GROUP} --query properties.runningStatus"
    echo ""
    echo "  # View logs"
    echo "  az containerapp logs show -n ${CA_NAME} -g ${RESOURCE_GROUP}"
    echo ""
    echo "  # Scale replicas"
    echo "  az containerapp update -n ${CA_NAME} -g ${RESOURCE_GROUP} --min-replicas 1 --max-replicas 3"
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
    echo "# Build image IN AZURE (no local Docker needed!)"
    echo "az acr build --registry <acr> --image myapp:v1 ."
    echo ""
    echo "# List repositories"
    echo "az acr repository list --name <acr> -o table"
    echo ""
    echo -e "${YELLOW}Azure Container Apps${NC}"
    echo ""
    echo "# Create environment"
    echo "az containerapp env create --name <env> --resource-group <rg> --location <loc>"
    echo ""
    echo "# Deploy container from ACR"
    echo "az containerapp create --name <app> --resource-group <rg> --environment <env> \\"
    echo "    --image <acr>.azurecr.io/myapp:v1 --target-port 8080 --ingress external"
    echo ""
    echo "# Check app status"
    echo "az containerapp show -n <app> -g <rg> --query properties.configuration.ingress.fqdn"
    echo ""
    echo "# View logs"
    echo "az containerapp logs show -n <app> -g <rg>"
    echo ""
    echo "# Scale replicas"
    echo "az containerapp update -n <app> -g <rg> --min-replicas 1 --max-replicas 5"
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
    --yes|-y)
        SKIP_CONFIRM=true
        deploy
        ;;
    *)
        deploy
        ;;
esac
