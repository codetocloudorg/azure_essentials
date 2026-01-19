#!/bin/bash
#===============================================================================
# Lesson 07: Container Services - ACR + AKS + Hello World
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# This script demonstrates the complete container workflow:
#   1. Create Azure Container Registry (ACR)
#   2. Build a container image in ACR
#   3. Create Azure Kubernetes Service (AKS) cluster
#   4. Deploy hello-container to AKS
#
# COST ESTIMATE:
#   ACR Basic:  ~$5/month
#   AKS (1 node Standard_B2s): ~$30/month
#   Total: ~$35/month
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - kubectl installed (az aks install-cli)
#
# Usage:
#   ./lesson-07-containers.sh              # Deploy ACR + AKS + app
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
AKS_NAME="aks-essentials-${UNIQUE_SUFFIX}"

# Get script directory for finding sample app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HELLO_APP_DIR="${REPO_ROOT}/lessons/07-container-services/src/hello-container"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 07: Container Services${NC}"
    echo -e "${CYAN}  ACR + AKS + Hello World Deployment${NC}"
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

    # Clean up kubeconfig
    print_step "Removing AKS credentials from kubeconfig..."
    kubectl config delete-context "${AKS_NAME}" 2>/dev/null || true
    kubectl config delete-cluster "${AKS_NAME}" 2>/dev/null || true

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
    print_info "AKS Cluster: ${AKS_NAME}"
    echo ""

    print_warning "This will create AKS (~\$30/month). Continue? (y/n)"
    read -r confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Deployment cancelled."
        exit 0
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
    # Step 4: Create AKS Cluster
    #---------------------------------------------------------------------------
    print_step "Creating AKS Cluster: ${AKS_NAME}"
    print_info "This takes 3-5 minutes..."
    echo ""

    az aks create \
        --name "$AKS_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --node-count 1 \
        --node-vm-size Standard_B2s \
        --enable-managed-identity \
        --attach-acr "$ACR_NAME" \
        --generate-ssh-keys \
        --tags "course=azure-essentials" "lesson=07-containers" \
        --output none

    print_success "AKS Cluster created"
    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Get AKS Credentials
    #---------------------------------------------------------------------------
    print_step "Getting AKS credentials for kubectl..."

    az aks get-credentials \
        --name "$AKS_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --overwrite-existing

    print_success "kubectl configured"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Deploy Hello Container to AKS
    #---------------------------------------------------------------------------
    print_step "Deploying hello-container to AKS..."

    # Create deployment with correct image
    kubectl create deployment hello-container \
        --image="${login_server}/hello-container:v1" \
        --replicas=2

    # Expose as LoadBalancer service
    kubectl expose deployment hello-container \
        --type=LoadBalancer \
        --port=80 \
        --target-port=8080

    print_success "Deployment created"
    echo ""

    #---------------------------------------------------------------------------
    # Step 7: Wait for External IP
    #---------------------------------------------------------------------------
    print_step "Waiting for external IP (this may take 1-2 minutes)..."

    local external_ip=""
    local attempts=0
    local max_attempts=24

    while [[ -z "$external_ip" || "$external_ip" == "<pending>" ]]; do
        external_ip=$(kubectl get svc hello-container -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
        if [[ -z "$external_ip" || "$external_ip" == "<pending>" ]]; then
            ((attempts++))
            if [[ $attempts -ge $max_attempts ]]; then
                print_warning "Timeout waiting for IP. Check later with: kubectl get svc hello-container"
                break
            fi
            echo -n "."
            sleep 5
        fi
    done
    echo ""

    if [[ -n "$external_ip" && "$external_ip" != "<pending>" ]]; then
        print_success "External IP: ${external_ip}"
    fi
    echo ""

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
    echo -e "${CYAN}Azure Kubernetes Service:${NC}"
    echo "  Name:         ${AKS_NAME}"
    echo "  Nodes:        1 x Standard_B2s (~\$30/month)"
    echo ""
    echo -e "${CYAN}Hello Container App:${NC}"
    if [[ -n "$external_ip" && "$external_ip" != "<pending>" ]]; then
        echo "  URL:          http://${external_ip}"
        echo ""
        echo -e "${YELLOW}🌐 Open in browser: ${BOLD}http://${external_ip}${NC}"
    else
        echo "  URL:          (pending - check: kubectl get svc hello-container)"
    fi
    echo ""
    echo -e "${CYAN}Useful Commands:${NC}"
    echo ""
    echo "  # Check pods"
    echo "  kubectl get pods"
    echo ""
    echo "  # Check service"
    echo "  kubectl get svc hello-container"
    echo ""
    echo "  # View pod logs"
    echo "  kubectl logs -l app=hello-container"
    echo ""
    echo "  # Scale deployment"
    echo "  kubectl scale deployment hello-container --replicas=3"
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
    echo -e "${YELLOW}Azure Kubernetes Service (AKS)${NC}"
    echo ""
    echo "# Create AKS cluster with ACR integration"
    echo "az aks create --name <aks> --resource-group <rg> --node-count 1 \\"
    echo "    --node-vm-size Standard_B2s --attach-acr <acr>"
    echo ""
    echo "# Get kubectl credentials"
    echo "az aks get-credentials --name <aks> --resource-group <rg>"
    echo ""
    echo "# Attach ACR to existing AKS"
    echo "az aks update --name <aks> --resource-group <rg> --attach-acr <acr>"
    echo ""
    echo -e "${YELLOW}Kubernetes (kubectl)${NC}"
    echo ""
    echo "# Create deployment"
    echo "kubectl create deployment myapp --image=<acr>.azurecr.io/myapp:v1"
    echo ""
    echo "# Expose as LoadBalancer"
    echo "kubectl expose deployment myapp --type=LoadBalancer --port=80 --target-port=8080"
    echo ""
    echo "# Check status"
    echo "kubectl get pods"
    echo "kubectl get svc"
    echo ""
    echo "# Scale"
    echo "kubectl scale deployment myapp --replicas=3"
    echo ""
    echo "# View logs"
    echo "kubectl logs -l app=myapp"
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
