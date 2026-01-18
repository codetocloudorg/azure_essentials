#!/bin/bash
#===============================================================================
# Lesson 06: Compute - Linux & Kubernetes - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create Linux VMs with MicroK8s
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Sufficient quota for B2s VMs
#
# Usage:
#   ./lesson-06-compute-linux.sh
#   ./lesson-06-compute-linux.sh --cleanup
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
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-linux}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
VM_NAME="vm-linux-${UNIQUE_SUFFIX}"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 06: Compute - Linux & Kubernetes${NC}"
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
    echo "Cleaning up Linux compute resources..."
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
    print_info "VM Name: ${VM_NAME}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=06-compute-linux"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Cloud-Init Configuration
    #---------------------------------------------------------------------------
    print_step "Preparing cloud-init configuration..."

    cat > /tmp/cloud-init.yaml << 'EOF'
#cloud-config
package_update: true
package_upgrade: true

packages:
  - snapd
  - curl
  - apt-transport-https

runcmd:
  # Install MicroK8s
  - snap install microk8s --classic

  # Add user to microk8s group
  - usermod -a -G microk8s azureuser

  # Create kube config directory
  - mkdir -p /home/azureuser/.kube
  - chown -R azureuser:azureuser /home/azureuser/.kube

  # Wait for MicroK8s to be ready
  - microk8s status --wait-ready

  # Enable common addons
  - microk8s enable dns
  - microk8s enable dashboard
  - microk8s enable storage
  - microk8s enable ingress

  # Create alias for kubectl
  - echo "alias kubectl='microk8s kubectl'" >> /home/azureuser/.bashrc

  # Generate kubeconfig
  - microk8s config > /home/azureuser/.kube/config
  - chown azureuser:azureuser /home/azureuser/.kube/config
EOF

    echo "  ✓ Cloud-init configuration created"
    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Create Ubuntu VM with Cloud-Init
    #---------------------------------------------------------------------------
    print_step "Creating Ubuntu 24.04 VM with MicroK8s (this takes 2-3 minutes)..."

    az vm create \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --image "Canonical:ubuntu-24_04-lts:server:latest" \
        --size "Standard_B2s" \
        --admin-username "azureuser" \
        --generate-ssh-keys \
        --public-ip-sku Standard \
        --custom-data /tmp/cloud-init.yaml \
        --tags "course=azure-essentials" "lesson=06"

    rm -f /tmp/cloud-init.yaml

    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Open Required Ports
    #---------------------------------------------------------------------------
    print_step "Opening ports for SSH and Kubernetes..."

    # SSH is already open, but let's be explicit
    az vm open-port \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --port 22 \
        --priority 1000 \
        --output none
    echo "  ✓ Port 22 (SSH) opened"

    # MicroK8s API server
    az vm open-port \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --port 16443 \
        --priority 1010 \
        --output none
    echo "  ✓ Port 16443 (Kubernetes API) opened"

    # HTTP/HTTPS for ingress
    az vm open-port \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --port 80 \
        --priority 1020 \
        --output none
    echo "  ✓ Port 80 (HTTP) opened"

    az vm open-port \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --port 443 \
        --priority 1030 \
        --output none
    echo "  ✓ Port 443 (HTTPS) opened"

    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Get VM Details
    #---------------------------------------------------------------------------
    print_step "Retrieving VM details..."

    local public_ip=$(az vm show \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --show-details \
        --query publicIps \
        -o tsv)

    local vm_size=$(az vm show \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query hardwareProfile.vmSize \
        -o tsv)

    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Linux VM:${NC}"
    echo "  Name:        ${VM_NAME}"
    echo "  Image:       Ubuntu 24.04 LTS"
    echo "  Size:        ${vm_size} (2 vCPUs, 4 GB RAM)"
    echo "  Public IP:   ${public_ip}"
    echo "  Username:    azureuser"
    echo ""
    echo -e "${CYAN}Connect via SSH:${NC}"
    echo "  ssh azureuser@${public_ip}"
    echo ""
    echo -e "${CYAN}MicroK8s Commands (after SSH):${NC}"
    echo "  microk8s status              # Check status"
    echo "  microk8s kubectl get nodes   # List nodes"
    echo "  microk8s kubectl get pods -A # List all pods"
    echo "  microk8s dashboard-proxy     # Start dashboard"
    echo ""
    echo -e "${YELLOW}Note:${NC} MicroK8s installation takes ~5 minutes after VM boot."
    echo "      Check progress with: tail -f /var/log/cloud-init-output.log"
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
    echo -e "${CYAN}Key Azure CLI Commands for Linux Compute:${NC}"
    echo ""
    echo "# Create Linux VM with SSH key"
    echo "az vm create --name <vm> --resource-group <rg> --image Ubuntu2204 \\"
    echo "    --size Standard_B2s --admin-username azureuser --generate-ssh-keys"
    echo ""
    echo "# Create VM with cloud-init"
    echo "az vm create --name <vm> --resource-group <rg> --image Ubuntu2204 \\"
    echo "    --custom-data cloud-init.yaml"
    echo ""
    echo "# Open port"
    echo "az vm open-port --name <vm> --resource-group <rg> --port 22"
    echo ""
    echo "# Get VM IP address"
    echo "az vm show --name <vm> --resource-group <rg> --show-details --query publicIps"
    echo ""
    echo "# Run command on VM"
    echo "az vm run-command invoke --name <vm> --resource-group <rg> \\"
    echo "    --command-id RunShellScript --scripts 'uname -a'"
    echo ""
    echo "# SSH to VM"
    echo "ssh azureuser@<public-ip>"
    echo ""
    echo "# Start/Stop/Deallocate VM"
    echo "az vm start --name <vm> --resource-group <rg>"
    echo "az vm stop --name <vm> --resource-group <rg>"
    echo "az vm deallocate --name <vm> --resource-group <rg>"
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
