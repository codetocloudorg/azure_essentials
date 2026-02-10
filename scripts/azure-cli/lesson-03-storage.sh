#!/bin/bash
#===============================================================================
# Lesson 03: Storage Services - Azure CLI Deployment
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# This script demonstrates how to create and manage Azure Storage resources
# using native Azure CLI commands. Perfect for Cloud Shell copy-paste.
#
# WHAT YOU'LL LEARN:
#   - Creating Storage Accounts with security best practices
#   - Working with Blob containers, Queues, Tables, and File shares
#   - Uploading and downloading data
#   - Generating SAS tokens for secure access
#
# AZURE CLI COMMANDS USED:
#   az storage account create    - Create storage account
#   az storage container create  - Create blob container
#   az storage blob upload       - Upload files to blob storage
#   az storage queue create      - Create message queue
#   az storage table create      - Create NoSQL table
#   az storage share create      - Create file share
#
# COST: Free tier eligible (5GB blob, 5GB file, 50K queue operations)
#
# PREREQUISITES:
#   - Azure CLI installed and logged in (az login)
#   - Alternatively, use Azure Cloud Shell (no setup needed)
#
# USAGE:
#   ./lesson-03-storage.sh           # Deploy resources
#   ./lesson-03-storage.sh --cleanup # Delete everything
#
# TRAINER TIP: Run each section separately to explain what's happening.
# Use 'az storage account show' to inspect created resources.
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
        --allow-shared-key-access true \
        --https-only true

    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Assign RBAC Role for Azure AD Authentication
    #---------------------------------------------------------------------------
    print_step "Assigning Storage Blob Data Contributor role..."
    
    # Get the current user's object ID
    USER_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || echo "")
    
    if [[ -n "$USER_ID" ]]; then
        az role assignment create \
            --role "Storage Blob Data Contributor" \
            --assignee "$USER_ID" \
            --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
            --output none 2>/dev/null || true
        
        az role assignment create \
            --role "Storage Queue Data Contributor" \
            --assignee "$USER_ID" \
            --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
            --output none 2>/dev/null || true
        
        az role assignment create \
            --role "Storage Table Data Contributor" \
            --assignee "$USER_ID" \
            --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
            --output none 2>/dev/null || true
        
        az role assignment create \
            --role "Storage File Data SMB Share Contributor" \
            --assignee "$USER_ID" \
            --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
            --output none 2>/dev/null || true
        
        echo "  ✓ RBAC roles assigned"
        # Wait for RBAC propagation
        echo "  ℹ Waiting for role propagation (30 seconds)..."
        sleep 30
    else
        echo -e "${YELLOW}  ⚠ Could not get user ID. Storage operations may fail.${NC}"
    fi
    
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Create Blob Containers
    #---------------------------------------------------------------------------
    print_step "Creating blob containers..."

    for container in "documents" "images" "backups"; do
        az storage container create \
            --name "$container" \
            --account-name "$STORAGE_ACCOUNT" \
            --auth-mode login \
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
        --auth-mode login \
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
        --auth-mode login \
        --output none

    echo "  ✓ Table created: logs"
    echo ""

    #---------------------------------------------------------------------------
    # Step 7: Create File Share
    #---------------------------------------------------------------------------
    print_step "Creating file share..."

    az storage share-rm create \
        --name "files" \
        --storage-account "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
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
        --auth-mode login \
        --container-name "documents" \
        --name "sample.txt" \
        --file /tmp/sample.txt \
        --overwrite \
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
        --auth-mode login \
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
    echo "# Create blob container (using OAuth authentication)"
    echo "az storage container create --name <name> --account-name <acct> --auth-mode login"
    echo ""
    echo "# Upload blob"
    echo "az storage blob upload --container-name <c> --name <blob> --file <path> --account-name <acct> --auth-mode login"
    echo ""
    echo "# Download blob"
    echo "az storage blob download --container-name <c> --name <blob> --file <path> --account-name <acct> --auth-mode login"
    echo ""
    echo "# List blobs"
    echo "az storage blob list --container-name <c> --account-name <acct> --auth-mode login -o table"
    echo ""
    echo "# Create queue"
    echo "az storage queue create --name <name> --account-name <acct> --auth-mode login"
    echo ""
    echo "# Create table"
    echo "az storage table create --name <name> --account-name <acct> --auth-mode login"
    echo ""
    echo "# Create file share (using Resource Manager)"
    echo "az storage share-rm create --name <name> --storage-account <acct> --resource-group <rg> --quota <gb>"
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
