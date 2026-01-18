#!/bin/bash
#===============================================================================
# Lesson 05: Compute - Windows - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create Windows VMs and App Service
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Sufficient quota for B1s VMs (1 vCPU)
#
# Usage:
#   ./lesson-05-compute-windows.sh
#   ./lesson-05-compute-windows.sh --cleanup
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
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-windows}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
VM_NAME="vm-win-${UNIQUE_SUFFIX}"
APP_NAME="app-essentials-${UNIQUE_SUFFIX}"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 05: Compute - Windows${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

#===============================================================================
# Cleanup Function
#===============================================================================

cleanup() {
    print_header
    echo "Cleaning up Windows compute resources..."
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

    #---------------------------------------------------------------------------
    # Get Password (from env var or prompt)
    #---------------------------------------------------------------------------
    if [[ -n "${ADMIN_PASSWORD:-}" ]]; then
        print_info "Using password from ADMIN_PASSWORD environment variable"
    else
        print_info "Windows VM requires an admin password."
        echo ""
        echo "Password requirements:"
        echo "  • At least 12 characters"
        echo "  • Contains uppercase letter"
        echo "  • Contains lowercase letter"
        echo "  • Contains number"
        echo ""
        echo "Tip: Set ADMIN_PASSWORD env var to skip this prompt"
        echo ""

        while true; do
            read -sp "Enter Windows admin password: " ADMIN_PASSWORD
            echo ""

            if [[ ${#ADMIN_PASSWORD} -lt 12 ]]; then
                echo -e "${RED}Password must be at least 12 characters${NC}"
                continue
            fi
            if [[ ! "$ADMIN_PASSWORD" =~ [A-Z] ]]; then
                echo -e "${RED}Password must contain uppercase letter${NC}"
                continue
            fi
            if [[ ! "$ADMIN_PASSWORD" =~ [a-z] ]]; then
                echo -e "${RED}Password must contain lowercase letter${NC}"
                continue
            fi
            if [[ ! "$ADMIN_PASSWORD" =~ [0-9] ]]; then
                echo -e "${RED}Password must contain a number${NC}"
                continue
            fi
            break
        done
    fi

    echo ""
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
        --tags "course=azure-essentials" "lesson=05-compute-windows"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Virtual Network
    #---------------------------------------------------------------------------
    print_step "Creating virtual network..."

    az network vnet create \
        --name "vnet-${VM_NAME}" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --address-prefix "10.1.0.0/16" \
        --subnet-name "default" \
        --subnet-prefix "10.1.0.0/24" \
        --output none

    echo "  ✓ VNet created: vnet-${VM_NAME}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Create Public IP
    #---------------------------------------------------------------------------
    print_step "Creating public IP address..."

    az network public-ip create \
        --name "pip-${VM_NAME}" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --allocation-method Static \
        --sku Standard \
        --dns-name "${VM_NAME}" \
        --output none

    echo "  ✓ Public IP created with DNS: ${VM_NAME}.${LOCATION}.cloudapp.azure.com"
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Create Network Security Group
    #---------------------------------------------------------------------------
    print_step "Creating NSG with RDP rule..."

    az network nsg create \
        --name "nsg-${VM_NAME}" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --output none

    az network nsg rule create \
        --name "AllowRDP" \
        --nsg-name "nsg-${VM_NAME}" \
        --resource-group "$RESOURCE_GROUP" \
        --priority 1000 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --source-address-prefixes "*" \
        --destination-port-ranges 3389 \
        --output none

    echo "  ✓ NSG created with RDP rule (port 3389)"
    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Create Network Interface
    #---------------------------------------------------------------------------
    print_step "Creating network interface..."

    az network nic create \
        --name "nic-${VM_NAME}" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --vnet-name "vnet-${VM_NAME}" \
        --subnet "default" \
        --public-ip-address "pip-${VM_NAME}" \
        --network-security-group "nsg-${VM_NAME}" \
        --output none

    echo "  ✓ NIC created and configured"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Create Windows VM
    #---------------------------------------------------------------------------
    print_step "Creating Windows Server 2022 VM (this takes 2-3 minutes)..."

    az vm create \
        --name "$VM_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --nics "nic-${VM_NAME}" \
        --image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest" \
        --size "Standard_B1s" \
        --admin-username "azureuser" \
        --admin-password "$ADMIN_PASSWORD" \
        --os-disk-name "${VM_NAME}-osdisk" \
        --storage-sku StandardSSD_LRS \
        --output none

    echo "  ✓ Windows VM created: ${VM_NAME}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 7: Configure Auto-Shutdown
    #---------------------------------------------------------------------------
    print_step "Configuring auto-shutdown (7 PM UTC)..."

    local sub_id=$(az account show --query id -o tsv)

    az resource create \
        --resource-group "$RESOURCE_GROUP" \
        --resource-type "Microsoft.DevTestLab/schedules" \
        --name "shutdown-computevm-${VM_NAME}" \
        --properties "{
            \"status\": \"Enabled\",
            \"taskType\": \"ComputeVmShutdownTask\",
            \"dailyRecurrence\": { \"time\": \"1900\" },
            \"timeZoneId\": \"UTC\",
            \"notificationSettings\": { \"status\": \"Disabled\" },
            \"targetResourceId\": \"/subscriptions/${sub_id}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Compute/virtualMachines/${VM_NAME}\"
        }" \
        --output none 2>/dev/null || print_warning "Auto-shutdown may need manual setup"

    echo "  ✓ Auto-shutdown configured for 7 PM UTC"
    echo ""

    #---------------------------------------------------------------------------
    # Step 8: Create App Service Plan
    #---------------------------------------------------------------------------
    print_step "Creating App Service Plan (Free tier)..."

    az appservice plan create \
        --name "asp-${UNIQUE_SUFFIX}" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku F1 \
        --output none

    echo "  ✓ App Service Plan created: asp-${UNIQUE_SUFFIX}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 9: Create Web App
    #---------------------------------------------------------------------------
    print_step "Creating Web App..."

    az webapp create \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --plan "asp-${UNIQUE_SUFFIX}" \
        --runtime "DOTNET|8.0" \
        --output none 2>/dev/null || az webapp create \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --plan "asp-${UNIQUE_SUFFIX}" \
        --output none

    echo "  ✓ Web App created: ${APP_NAME}"
    echo ""

    #---------------------------------------------------------------------------
    # Get Outputs
    #---------------------------------------------------------------------------
    local public_ip=$(az network public-ip show \
        --name "pip-${VM_NAME}" \
        --resource-group "$RESOURCE_GROUP" \
        --query ipAddress \
        -o tsv)

    local fqdn=$(az network public-ip show \
        --name "pip-${VM_NAME}" \
        --resource-group "$RESOURCE_GROUP" \
        --query dnsSettings.fqdn \
        -o tsv)

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Windows VM:${NC}"
    echo "  Name:        ${VM_NAME}"
    echo "  Image:       Windows Server 2022 Datacenter"
    echo "  Size:        Standard_B1s (1 vCPU, 1 GB RAM)"
    echo "  Public IP:   ${public_ip}"
    echo "  FQDN:        ${fqdn}"
    echo "  Username:    azureuser"
    echo ""
    echo -e "${CYAN}Connect via RDP:${NC}"
    echo "  Windows:     mstsc /v:${fqdn}"
    echo "  macOS/Linux: Use Microsoft Remote Desktop app"
    echo ""
    echo -e "${CYAN}App Service:${NC}"
    echo "  Name: ${APP_NAME}"
    echo "  URL:  https://${APP_NAME}.azurewebsites.net"
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
    echo -e "${CYAN}Key Azure CLI Commands for Windows Compute:${NC}"
    echo ""
    echo "# Create Windows VM"
    echo "az vm create --name <vm> --resource-group <rg> --image Win2022Datacenter \\"
    echo "    --size Standard_B1s --admin-username azureuser"
    echo ""
    echo "# Open port on VM"
    echo "az vm open-port --name <vm> --resource-group <rg> --port 3389"
    echo ""
    echo "# Get VM public IP"
    echo "az vm show --name <vm> --resource-group <rg> --show-details --query publicIps"
    echo ""
    echo "# Start/Stop VM"
    echo "az vm start --name <vm> --resource-group <rg>"
    echo "az vm stop --name <vm> --resource-group <rg>"
    echo "az vm deallocate --name <vm> --resource-group <rg>  # Stops billing"
    echo ""
    echo "# Resize VM"
    echo "az vm resize --name <vm> --resource-group <rg> --size Standard_B4ms"
    echo ""
    echo "# Create App Service"
    echo "az appservice plan create --name <plan> --resource-group <rg> --sku F1"
    echo "az webapp create --name <app> --plan <plan> --resource-group <rg>"
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
