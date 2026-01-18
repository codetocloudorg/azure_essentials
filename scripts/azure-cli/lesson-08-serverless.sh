#!/bin/bash
#===============================================================================
# Lesson 08: Serverless Services - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create Azure Functions
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#
# Usage:
#   ./lesson-08-serverless.sh
#   ./lesson-08-serverless.sh --cleanup
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
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-serverless}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
STORAGE_ACCOUNT="stfunc${UNIQUE_SUFFIX}"
FUNCTION_APP="func-essentials-${UNIQUE_SUFFIX}"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 08: Serverless Services${NC}"
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
    echo "Cleaning up serverless resources..."
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
    print_info "Function App: ${FUNCTION_APP}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=08-serverless"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Storage Account (Required for Functions)
    #---------------------------------------------------------------------------
    print_step "Creating storage account: ${STORAGE_ACCOUNT}"

    az storage account create \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --output none

    echo "  ✓ Storage account created (required for Functions)"
    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Create Function App (Consumption Plan - Serverless)
    #---------------------------------------------------------------------------
    print_step "Creating Function App (Python 3.11, Consumption Plan)..."

    az functionapp create \
        --name "$FUNCTION_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --storage-account "$STORAGE_ACCOUNT" \
        --consumption-plan-location "$LOCATION" \
        --runtime python \
        --runtime-version 3.11 \
        --functions-version 4 \
        --os-type Linux

    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Show Function App Details
    #---------------------------------------------------------------------------
    print_step "Function App details:"

    az functionapp show \
        --name "$FUNCTION_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --query "{Name:name, State:state, DefaultHostName:defaultHostName, Runtime:siteConfig.linuxFxVersion}" \
        -o table

    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Configure App Settings
    #---------------------------------------------------------------------------
    print_step "Configuring app settings..."

    az functionapp config appsettings set \
        --name "$FUNCTION_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --settings "FUNCTIONS_WORKER_RUNTIME=python" \
        --output none

    echo "  ✓ Runtime configured for Python"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Get Function URL
    #---------------------------------------------------------------------------
    local func_url=$(az functionapp show \
        --name "$FUNCTION_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --query defaultHostName \
        -o tsv)

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Azure Function App:${NC}"
    echo "  Name:         ${FUNCTION_APP}"
    echo "  URL:          https://${func_url}"
    echo "  Runtime:      Python 3.11"
    echo "  Plan:         Consumption (Serverless)"
    echo "  Storage:      ${STORAGE_ACCOUNT}"
    echo ""
    echo -e "${CYAN}Deploy Code with Azure Functions Core Tools:${NC}"
    echo ""
    echo "  # Install Azure Functions Core Tools"
    echo "  npm install -g azure-functions-core-tools@4"
    echo ""
    echo "  # Create a new function project"
    echo "  func init MyFunctionApp --python"
    echo "  cd MyFunctionApp"
    echo "  func new --name HttpTrigger --template 'HTTP trigger'"
    echo ""
    echo "  # Deploy to Azure"
    echo "  func azure functionapp publish ${FUNCTION_APP}"
    echo ""
    echo -e "${CYAN}Or deploy from lessons/08-serverless/src:${NC}"
    echo "  cd lessons/08-serverless/src/sample-function"
    echo "  func azure functionapp publish ${FUNCTION_APP}"
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
    echo -e "${CYAN}Key Azure CLI Commands for Serverless:${NC}"
    echo ""
    echo "# Create function app (Consumption Plan)"
    echo "az functionapp create --name <func> --resource-group <rg> \\"
    echo "    --storage-account <storage> --consumption-plan-location <loc> \\"
    echo "    --runtime python --runtime-version 3.11 --functions-version 4"
    echo ""
    echo "# Create function app (Dedicated Plan)"
    echo "az functionapp plan create --name <plan> --resource-group <rg> --sku B1"
    echo "az functionapp create --name <func> --plan <plan> --storage-account <storage>"
    echo ""
    echo "# List functions in app"
    echo "az functionapp function list --name <func> --resource-group <rg>"
    echo ""
    echo "# Get function URL"
    echo "az functionapp function show --name <func> --resource-group <rg> \\"
    echo "    --function-name <function> --query invokeUrlTemplate"
    echo ""
    echo "# View app settings"
    echo "az functionapp config appsettings list --name <func> --resource-group <rg>"
    echo ""
    echo "# Set app settings"
    echo "az functionapp config appsettings set --name <func> --resource-group <rg> \\"
    echo "    --settings 'KEY=value'"
    echo ""
    echo "# Start/Stop/Restart"
    echo "az functionapp start --name <func> --resource-group <rg>"
    echo "az functionapp stop --name <func> --resource-group <rg>"
    echo "az functionapp restart --name <func> --resource-group <rg>"
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
