#!/bin/bash
#===============================================================================
# Lesson 03: Storage Services - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create and manage Azure Storage resources
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#
# Usage:
#   ./lesson-03-storage.sh
#   ./lesson-03-storage.sh --cleanup
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
LOCATION="${LOCATION:-uksouth}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-storage}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
STORAGE_ACCOUNT="stessentials${UNIQUE_SUFFIX}"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 03: Storage Services${NC}"
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
    echo "Cleaning up storage resources..."
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
    print_info "Storage Account: ${STORAGE_ACCOUNT}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=03-storage"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Storage Account
    #---------------------------------------------------------------------------
    print_step "Creating storage account: ${STORAGE_ACCOUNT}"

    az storage account create \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --access-tier Hot \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access false \
        --https-only true

    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Get Storage Account Key
    #---------------------------------------------------------------------------
    print_step "Retrieving storage account key..."

    ACCOUNT_KEY=$(az storage account keys list \
        --account-name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --query '[0].value' \
        -o tsv)

    echo "  ✓ Key retrieved"
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Create Blob Containers
    #---------------------------------------------------------------------------
    print_step "Creating blob containers..."

    for container in "documents" "images" "backups"; do
        az storage container create \
            --name "$container" \
            --account-name "$STORAGE_ACCOUNT" \
            --account-key "$ACCOUNT_KEY" \
            --output none
        echo "  ✓ Container created: $container"
    done

    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Create Queue
    #---------------------------------------------------------------------------
    print_step "Creating storage queue..."

    az storage queue create \
        --name "messages" \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --output none

    echo "  ✓ Queue created: messages"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Create Table
    #---------------------------------------------------------------------------
    print_step "Creating storage table..."

    az storage table create \
        --name "logs" \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --output none

    echo "  ✓ Table created: logs"
    echo ""

    #---------------------------------------------------------------------------
    # Step 7: Create File Share
    #---------------------------------------------------------------------------
    print_step "Creating file share..."

    az storage share create \
        --name "files" \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --quota 5 \
        --output none

    echo "  ✓ File share created: files (5 GB quota)"
    echo ""

    #---------------------------------------------------------------------------
    # Step 8: Upload Sample Blob
    #---------------------------------------------------------------------------
    print_step "Uploading sample blob..."

    echo "Hello from Azure Essentials!" > /tmp/sample.txt

    az storage blob upload \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --container-name "documents" \
        --name "sample.txt" \
        --file /tmp/sample.txt \
        --output none

    rm /tmp/sample.txt
    echo "  ✓ Blob uploaded: documents/sample.txt"
    echo ""

    #---------------------------------------------------------------------------
    # Step 9: List Blobs
    #---------------------------------------------------------------------------
    print_step "Listing blobs in 'documents' container:"

    az storage blob list \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --container-name "documents" \
        --query "[].{Name:name, Size:properties.contentLength}" \
        -o table

    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    local endpoint=$(az storage account show \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --query primaryEndpoints.blob \
        -o tsv)

    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Storage Account: ${STORAGE_ACCOUNT}"
    echo "Blob Endpoint:   ${endpoint}"
    echo ""
    echo "Resources Created:"
    echo "  • Blob Containers: documents, images, backups"
    echo "  • Queue: messages"
    echo "  • Table: logs"
    echo "  • File Share: files"
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
    echo -e "${CYAN}Key Azure CLI Commands for Storage:${NC}"
    echo ""
    echo "# Create storage account"
    echo "az storage account create --name <name> --resource-group <rg> --sku Standard_LRS"
    echo ""
    echo "# List storage account keys"
    echo "az storage account keys list --account-name <name> --resource-group <rg>"
    echo ""
    echo "# Create blob container"
    echo "az storage container create --name <name> --account-name <acct>"
    echo ""
    echo "# Upload blob"
    echo "az storage blob upload --container-name <c> --name <blob> --file <path>"
    echo ""
    echo "# Download blob"
    echo "az storage blob download --container-name <c> --name <blob> --file <path>"
    echo ""
    echo "# List blobs"
    echo "az storage blob list --container-name <c> --account-name <acct> -o table"
    echo ""
    echo "# Create queue"
    echo "az storage queue create --name <name> --account-name <acct>"
    echo ""
    echo "# Create table"
    echo "az storage table create --name <name> --account-name <acct>"
    echo ""
    echo "# Create file share"
    echo "az storage share create --name <name> --account-name <acct> --quota <gb>"
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
