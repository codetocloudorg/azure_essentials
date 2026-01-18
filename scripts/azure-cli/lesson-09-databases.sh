#!/bin/bash
#===============================================================================
# Lesson 09: Database & Data Services - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create Azure Cosmos DB
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#
# Usage:
#   ./lesson-09-databases.sh
#   ./lesson-09-databases.sh --cleanup
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
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-databases}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
COSMOS_ACCOUNT="cosmos-essentials-${UNIQUE_SUFFIX}"
DATABASE_NAME="coursedb"
CONTAINER_NAME="items"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 09: Database Services${NC}"
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
    echo "Cleaning up database resources..."
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
    print_info "Cosmos Account: ${COSMOS_ACCOUNT}"
    echo ""
    print_warning "Cosmos DB account creation takes 3-5 minutes."
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=09-databases"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Cosmos DB Account (Serverless)
    #---------------------------------------------------------------------------
    print_step "Creating Cosmos DB account (Serverless, this takes 3-5 minutes)..."

    az cosmosdb create \
        --name "$COSMOS_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --locations regionName="$LOCATION" failoverPriority=0 isZoneRedundant=false \
        --default-consistency-level Session \
        --capabilities EnableServerless \
        --kind GlobalDocumentDB

    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Create SQL Database
    #---------------------------------------------------------------------------
    print_step "Creating SQL database: ${DATABASE_NAME}"

    az cosmosdb sql database create \
        --account-name "$COSMOS_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DATABASE_NAME"

    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Create Container
    #---------------------------------------------------------------------------
    print_step "Creating container: ${CONTAINER_NAME}"

    az cosmosdb sql container create \
        --account-name "$COSMOS_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --database-name "$DATABASE_NAME" \
        --name "$CONTAINER_NAME" \
        --partition-key-path "/category"

    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Get Connection Details
    #---------------------------------------------------------------------------
    print_step "Retrieving connection details..."

    local endpoint=$(az cosmosdb show \
        --name "$COSMOS_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --query documentEndpoint \
        -o tsv)

    local primary_key=$(az cosmosdb keys list \
        --name "$COSMOS_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --query primaryMasterKey \
        -o tsv)

    local connection_string=$(az cosmosdb keys list \
        --name "$COSMOS_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --type connection-strings \
        --query "connectionStrings[0].connectionString" \
        -o tsv)

    echo "  ✓ Connection details retrieved"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Insert Sample Document
    #---------------------------------------------------------------------------
    print_step "Inserting sample document..."

    # Note: az cosmosdb sql container doesn't have direct document operations
    # Show how to do it with the REST API or SDK instead
    echo "  Use the Python SDK or Azure Portal to insert documents."
    echo "  Sample document structure:"
    echo '  {
    "id": "1",
    "category": "learning",
    "name": "Azure Essentials Course",
    "description": "Learn Azure fundamentals"
  }'
    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Azure Cosmos DB:${NC}"
    echo "  Account:    ${COSMOS_ACCOUNT}"
    echo "  Endpoint:   ${endpoint}"
    echo "  Database:   ${DATABASE_NAME}"
    echo "  Container:  ${CONTAINER_NAME}"
    echo "  Mode:       Serverless (pay per request)"
    echo ""
    echo -e "${CYAN}Primary Key:${NC}"
    echo "  ${primary_key:0:20}..."
    echo ""
    echo -e "${CYAN}Connection String:${NC}"
    echo "  ${connection_string:0:60}..."
    echo ""
    echo -e "${CYAN}Python SDK Example:${NC}"
    echo '  from azure.cosmos import CosmosClient'
    echo ''
    echo "  client = CosmosClient('${endpoint}', '${primary_key:0:10}...')"
    echo "  database = client.get_database_client('${DATABASE_NAME}')"
    echo "  container = database.get_container_client('${CONTAINER_NAME}')"
    echo ''
    echo "  # Insert item"
    echo "  container.upsert_item({'id': '1', 'category': 'test', 'name': 'Hello'})"
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
    echo -e "${CYAN}Key Azure CLI Commands for Cosmos DB:${NC}"
    echo ""
    echo "# Create Cosmos DB account (Serverless)"
    echo "az cosmosdb create --name <account> --resource-group <rg> \\"
    echo "    --capabilities EnableServerless"
    echo ""
    echo "# Create Cosmos DB account (Provisioned throughput)"
    echo "az cosmosdb create --name <account> --resource-group <rg>"
    echo ""
    echo "# Create SQL database"
    echo "az cosmosdb sql database create --account-name <acct> --name <db>"
    echo ""
    echo "# Create SQL container"
    echo "az cosmosdb sql container create --account-name <acct> --database-name <db> \\"
    echo "    --name <container> --partition-key-path '/partitionKey'"
    echo ""
    echo "# Get connection keys"
    echo "az cosmosdb keys list --name <account> --resource-group <rg>"
    echo ""
    echo "# Get connection strings"
    echo "az cosmosdb keys list --name <account> --resource-group <rg> --type connection-strings"
    echo ""
    echo "# Show account details"
    echo "az cosmosdb show --name <account> --resource-group <rg>"
    echo ""
    echo "# List databases"
    echo "az cosmosdb sql database list --account-name <account> --resource-group <rg>"
    echo ""
    echo "# List containers"
    echo "az cosmosdb sql container list --account-name <acct> --database-name <db>"
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
