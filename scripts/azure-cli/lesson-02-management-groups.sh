#!/bin/bash
#===============================================================================
# Lesson 02: Management Groups - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create and manage Azure Management Groups
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Tenant-level permissions (Global Admin or Management Group Contributor)
#
# Usage:
#   ./lesson-02-management-groups.sh
#   ./lesson-02-management-groups.sh --cleanup
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
MG_PREFIX="${MG_PREFIX:-mg-essentials}"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 02: Management Groups${NC}"
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
    echo "Cleaning up Management Groups..."
    echo ""

    # Delete in reverse order (children first)
    for mg in "sandbox" "development" "production"; do
        print_step "Deleting ${MG_PREFIX}-${mg}..."
        az account management-group delete \
            --name "${MG_PREFIX}-${mg}" \
            2>/dev/null || echo "  (not found or already deleted)"
    done

    print_step "Deleting ${MG_PREFIX}-root..."
    az account management-group delete \
        --name "${MG_PREFIX}-root" \
        2>/dev/null || echo "  (not found or already deleted)"

    echo ""
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

#===============================================================================
# Deploy Function
#===============================================================================

deploy() {
    print_header

    print_warning "Management Groups require Tenant-level permissions."
    echo ""

    # Get tenant info
    local tenant_id=$(az account show --query tenantId -o tsv)
    print_info "Tenant ID: ${tenant_id}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Root Management Group
    #---------------------------------------------------------------------------
    print_step "Creating root management group: ${MG_PREFIX}-root"

    az account management-group create \
        --name "${MG_PREFIX}-root" \
        --display-name "Azure Essentials Root"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Child Management Groups
    #---------------------------------------------------------------------------
    print_step "Creating child management groups..."

    # Production
    az account management-group create \
        --name "${MG_PREFIX}-production" \
        --display-name "Production" \
        --parent "${MG_PREFIX}-root"
    echo "  ✓ Created: ${MG_PREFIX}-production"

    # Development
    az account management-group create \
        --name "${MG_PREFIX}-development" \
        --display-name "Development" \
        --parent "${MG_PREFIX}-root"
    echo "  ✓ Created: ${MG_PREFIX}-development"

    # Sandbox
    az account management-group create \
        --name "${MG_PREFIX}-sandbox" \
        --display-name "Sandbox" \
        --parent "${MG_PREFIX}-root"
    echo "  ✓ Created: ${MG_PREFIX}-sandbox"

    echo ""

    #---------------------------------------------------------------------------
    # Step 3: List Management Groups
    #---------------------------------------------------------------------------
    print_step "Listing management group hierarchy:"

    az account management-group list \
        --query "[?contains(name, '${MG_PREFIX}')].{Name:name, DisplayName:displayName}" \
        -o table

    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Management Groups Created:"
    echo "  └── ${MG_PREFIX}-root (Azure Essentials Root)"
    echo "      ├── ${MG_PREFIX}-production (Production)"
    echo "      ├── ${MG_PREFIX}-development (Development)"
    echo "      └── ${MG_PREFIX}-sandbox (Sandbox)"
    echo ""
    echo "View in Portal:"
    echo "  https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups"
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
    echo -e "${CYAN}Key Azure CLI Commands for Management Groups:${NC}"
    echo ""
    echo "# Create a management group"
    echo "az account management-group create --name <name> --display-name <display>"
    echo ""
    echo "# Create a child management group"
    echo "az account management-group create --name <name> --parent <parent-name>"
    echo ""
    echo "# List all management groups"
    echo "az account management-group list -o table"
    echo ""
    echo "# Show management group details"
    echo "az account management-group show --name <name>"
    echo ""
    echo "# Move subscription to management group"
    echo "az account management-group subscription add --name <mg> --subscription <sub-id>"
    echo ""
    echo "# Delete a management group"
    echo "az account management-group delete --name <name>"
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
