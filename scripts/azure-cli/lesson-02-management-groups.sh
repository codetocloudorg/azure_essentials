#!/bin/bash
#===============================================================================
# Lesson 02: Management Groups - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create and manage Azure Management Groups
# using native Azure CLI commands.
#
# Creates an Azure Landing Zone style hierarchy:
#   mg-{prefix}-root
#   ├── mg-{prefix}-platform
#   │   ├── mg-{prefix}-identity
#   │   ├── mg-{prefix}-connectivity
#   │   └── mg-{prefix}-management
#   ├── mg-{prefix}-workloads
#   │   ├── mg-{prefix}-prod
#   │   └── mg-{prefix}-nonprod
#   └── mg-{prefix}-sandbox
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
    echo -e "${YELLOW}Note: Must delete child groups before parents.${NC}"
    echo ""

    # Delete leaf nodes first (deepest children)
    print_step "Deleting Platform child groups..."
    for mg in "identity" "connectivity" "management"; do
        az account management-group delete \
            --name "${MG_PREFIX}-${mg}" \
            2>/dev/null && echo "  ✓ Deleted ${MG_PREFIX}-${mg}" || echo "  (${mg} not found)"
    done

    print_step "Deleting Workloads child groups..."
    for mg in "prod" "nonprod"; do
        az account management-group delete \
            --name "${MG_PREFIX}-${mg}" \
            2>/dev/null && echo "  ✓ Deleted ${MG_PREFIX}-${mg}" || echo "  (${mg} not found)"
    done

    # Delete second level
    print_step "Deleting second-level groups..."
    for mg in "platform" "workloads" "sandbox"; do
        az account management-group delete \
            --name "${MG_PREFIX}-${mg}" \
            2>/dev/null && echo "  ✓ Deleted ${MG_PREFIX}-${mg}" || echo "  (${mg} not found)"
    done

    # Delete root last
    print_step "Deleting root management group..."
    az account management-group delete \
        --name "${MG_PREFIX}-root" \
        2>/dev/null && echo "  ✓ Deleted ${MG_PREFIX}-root" || echo "  (root not found)"

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

    echo "This will create an Azure Landing Zone style hierarchy:"
    echo ""
    echo "  📁 ${MG_PREFIX}-root (Organization Root)"
    echo "  ├── 📁 ${MG_PREFIX}-platform"
    echo "  │   ├── 📁 ${MG_PREFIX}-identity"
    echo "  │   ├── 📁 ${MG_PREFIX}-connectivity"
    echo "  │   └── 📁 ${MG_PREFIX}-management"
    echo "  ├── 📁 ${MG_PREFIX}-workloads"
    echo "  │   ├── 📁 ${MG_PREFIX}-prod"
    echo "  │   └── 📁 ${MG_PREFIX}-nonprod"
    echo "  └── 📁 ${MG_PREFIX}-sandbox"
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Root Management Group
    #---------------------------------------------------------------------------
    print_step "Creating root management group: ${MG_PREFIX}-root"

    az account management-group create \
        --name "${MG_PREFIX}-root" \
        --display-name "Organization Root"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Second-Level Management Groups (under root)
    #---------------------------------------------------------------------------
    print_step "Creating second-level management groups..."

    # Platform
    az account management-group create \
        --name "${MG_PREFIX}-platform" \
        --display-name "Platform" \
        --parent "${MG_PREFIX}-root"
    echo "  ✓ Created: ${MG_PREFIX}-platform"

    # Workloads
    az account management-group create \
        --name "${MG_PREFIX}-workloads" \
        --display-name "Workloads" \
        --parent "${MG_PREFIX}-root"
    echo "  ✓ Created: ${MG_PREFIX}-workloads"

    # Sandbox
    az account management-group create \
        --name "${MG_PREFIX}-sandbox" \
        --display-name "Sandbox" \
        --parent "${MG_PREFIX}-root"
    echo "  ✓ Created: ${MG_PREFIX}-sandbox"

    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Create Platform Child Groups
    #---------------------------------------------------------------------------
    print_step "Creating Platform child management groups..."

    # Identity
    az account management-group create \
        --name "${MG_PREFIX}-identity" \
        --display-name "Identity" \
        --parent "${MG_PREFIX}-platform"
    echo "  ✓ Created: ${MG_PREFIX}-identity"

    # Connectivity
    az account management-group create \
        --name "${MG_PREFIX}-connectivity" \
        --display-name "Connectivity" \
        --parent "${MG_PREFIX}-platform"
    echo "  ✓ Created: ${MG_PREFIX}-connectivity"

    # Management
    az account management-group create \
        --name "${MG_PREFIX}-management" \
        --display-name "Management" \
        --parent "${MG_PREFIX}-platform"
    echo "  ✓ Created: ${MG_PREFIX}-management"

    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Create Workloads Child Groups
    #---------------------------------------------------------------------------
    print_step "Creating Workloads child management groups..."

    # Production
    az account management-group create \
        --name "${MG_PREFIX}-prod" \
        --display-name "Production" \
        --parent "${MG_PREFIX}-workloads"
    echo "  ✓ Created: ${MG_PREFIX}-prod"

    # Non-Production
    az account management-group create \
        --name "${MG_PREFIX}-nonprod" \
        --display-name "Non-Production" \
        --parent "${MG_PREFIX}-workloads"
    echo "  ✓ Created: ${MG_PREFIX}-nonprod"

    echo ""

    #---------------------------------------------------------------------------
    # Step 5: List Management Groups
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
    echo "Management Groups Created (9 total):"
    echo ""
    echo "  📁 ${MG_PREFIX}-root"
    echo "  ├── 📁 ${MG_PREFIX}-platform"
    echo "  │   ├── 📁 ${MG_PREFIX}-identity"
    echo "  │   ├── 📁 ${MG_PREFIX}-connectivity"
    echo "  │   └── 📁 ${MG_PREFIX}-management"
    echo "  ├── 📁 ${MG_PREFIX}-workloads"
    echo "  │   ├── 📁 ${MG_PREFIX}-prod"
    echo "  │   └── 📁 ${MG_PREFIX}-nonprod"
    echo "  └── 📁 ${MG_PREFIX}-sandbox"
    echo "  └── 📁 ${MG_PREFIX}-sandbox"
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
