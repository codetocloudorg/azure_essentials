#!/bin/bash
#===============================================================================
# Lesson 04: Networking Services - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create and manage Azure networking resources
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#
# Usage:
#   ./lesson-04-networking.sh
#   ./lesson-04-networking.sh --cleanup
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
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-networking}"
VNET_NAME="vnet-essentials"
NSG_NAME="nsg-essentials-web"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 04: Networking Services${NC}"
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
    echo "Cleaning up networking resources..."
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
    print_info "Virtual Network: ${VNET_NAME}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=04-networking"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Virtual Network with Subnets
    #---------------------------------------------------------------------------
    print_step "Creating virtual network: ${VNET_NAME}"

    az network vnet create \
        --name "$VNET_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --address-prefix "10.0.0.0/16" \
        --subnet-name "snet-web" \
        --subnet-prefix "10.0.1.0/24"

    echo "  ✓ VNet created with address space: 10.0.0.0/16"
    echo "  ✓ Subnet created: snet-web (10.0.1.0/24)"
    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Create Additional Subnets
    #---------------------------------------------------------------------------
    print_step "Creating additional subnets..."

    # Application tier subnet
    az network vnet subnet create \
        --name "snet-app" \
        --vnet-name "$VNET_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --address-prefixes "10.0.2.0/24"
    echo "  ✓ Subnet created: snet-app (10.0.2.0/24)"

    # Data tier subnet
    az network vnet subnet create \
        --name "snet-data" \
        --vnet-name "$VNET_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --address-prefixes "10.0.3.0/24"
    echo "  ✓ Subnet created: snet-data (10.0.3.0/24)"

    # Bastion subnet (requires specific name)
    az network vnet subnet create \
        --name "AzureBastionSubnet" \
        --vnet-name "$VNET_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --address-prefixes "10.0.255.0/26"
    echo "  ✓ Subnet created: AzureBastionSubnet (10.0.255.0/26)"

    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Create Network Security Group
    #---------------------------------------------------------------------------
    print_step "Creating network security group: ${NSG_NAME}"

    az network nsg create \
        --name "$NSG_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION"

    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Add NSG Rules
    #---------------------------------------------------------------------------
    print_step "Adding NSG security rules..."

    # Allow HTTP
    az network nsg rule create \
        --name "AllowHTTP" \
        --nsg-name "$NSG_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --priority 100 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --source-address-prefixes "*" \
        --source-port-ranges "*" \
        --destination-address-prefixes "*" \
        --destination-port-ranges 80 \
        --output none
    echo "  ✓ Rule: AllowHTTP (port 80, priority 100)"

    # Allow HTTPS
    az network nsg rule create \
        --name "AllowHTTPS" \
        --nsg-name "$NSG_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --priority 110 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --source-address-prefixes "*" \
        --source-port-ranges "*" \
        --destination-address-prefixes "*" \
        --destination-port-ranges 443 \
        --output none
    echo "  ✓ Rule: AllowHTTPS (port 443, priority 110)"

    # Deny all other inbound (explicit)
    az network nsg rule create \
        --name "DenyAllInbound" \
        --nsg-name "$NSG_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --priority 4096 \
        --direction Inbound \
        --access Deny \
        --protocol "*" \
        --source-address-prefixes "*" \
        --source-port-ranges "*" \
        --destination-address-prefixes "*" \
        --destination-port-ranges "*" \
        --output none
    echo "  ✓ Rule: DenyAllInbound (priority 4096)"

    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Associate NSG with Subnet
    #---------------------------------------------------------------------------
    print_step "Associating NSG with snet-web subnet..."

    az network vnet subnet update \
        --name "snet-web" \
        --vnet-name "$VNET_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --network-security-group "$NSG_NAME" \
        --output none

    echo "  ✓ NSG associated with snet-web"
    echo ""

    #---------------------------------------------------------------------------
    # Step 7: Show VNet Details
    #---------------------------------------------------------------------------
    print_step "Virtual Network configuration:"

    az network vnet show \
        --name "$VNET_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "{Name:name, AddressSpace:addressSpace.addressPrefixes[0], Subnets:subnets[].{Name:name, Prefix:addressPrefix}}" \
        -o json

    echo ""

    #---------------------------------------------------------------------------
    # Step 8: Show NSG Rules
    #---------------------------------------------------------------------------
    print_step "NSG security rules:"

    az network nsg rule list \
        --nsg-name "$NSG_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].{Name:name, Priority:priority, Direction:direction, Access:access, Port:destinationPortRange}" \
        -o table

    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Virtual Network: ${VNET_NAME}"
    echo "Address Space:   10.0.0.0/16"
    echo ""
    echo "Subnets:"
    echo "  ├── snet-web  (10.0.1.0/24)   - Web tier, NSG attached"
    echo "  ├── snet-app  (10.0.2.0/24)   - Application tier"
    echo "  ├── snet-data (10.0.3.0/24)   - Data tier"
    echo "  └── AzureBastionSubnet (10.0.255.0/26)"
    echo ""
    echo "NSG: ${NSG_NAME}"
    echo "  Rules: AllowHTTP, AllowHTTPS, DenyAllInbound"
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
    echo -e "${CYAN}Key Azure CLI Commands for Networking:${NC}"
    echo ""
    echo "# Create virtual network"
    echo "az network vnet create --name <vnet> --resource-group <rg> --address-prefix 10.0.0.0/16"
    echo ""
    echo "# Create subnet"
    echo "az network vnet subnet create --name <subnet> --vnet-name <vnet> --address-prefixes 10.0.1.0/24"
    echo ""
    echo "# List subnets"
    echo "az network vnet subnet list --vnet-name <vnet> --resource-group <rg> -o table"
    echo ""
    echo "# Create NSG"
    echo "az network nsg create --name <nsg> --resource-group <rg>"
    echo ""
    echo "# Create NSG rule"
    echo "az network nsg rule create --name <rule> --nsg-name <nsg> --priority 100 \\"
    echo "    --direction Inbound --access Allow --protocol Tcp --destination-port-ranges 80"
    echo ""
    echo "# Associate NSG with subnet"
    echo "az network vnet subnet update --name <subnet> --vnet-name <vnet> --network-security-group <nsg>"
    echo ""
    echo "# Show VNet"
    echo "az network vnet show --name <vnet> --resource-group <rg>"
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
