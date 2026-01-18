#!/bin/bash
#===============================================================================
# Lesson 11: AI Foundry - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create Azure AI Services
# using native Azure CLI commands.
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Appropriate permissions for Cognitive Services
#
# Usage:
#   ./lesson-11-ai-foundry.sh
#   ./lesson-11-ai-foundry.sh --cleanup
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
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-ai}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
AI_ACCOUNT="ai-essentials-${UNIQUE_SUFFIX}"

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 11: AI Foundry${NC}"
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
    echo "Cleaning up AI resources..."
    echo ""

    print_step "Deleting resource group: ${RESOURCE_GROUP}"
    az group delete \
        --name "$RESOURCE_GROUP" \
        --yes \
        --no-wait

    echo ""
    echo -e "${GREEN}✓ Cleanup initiated (runs in background)${NC}"
    echo ""
    print_warning "Cognitive Services accounts are soft-deleted."
    echo "To permanently delete, use:"
    echo "  az cognitiveservices account purge --name ${AI_ACCOUNT} --resource-group ${RESOURCE_GROUP} --location ${LOCATION}"
}

#===============================================================================
# Deploy Function
#===============================================================================

deploy() {
    print_header

    print_info "Location: ${LOCATION}"
    print_info "Resource Group: ${RESOURCE_GROUP}"
    print_info "AI Account: ${AI_ACCOUNT}"
    echo ""
    print_warning "Azure OpenAI requires subscription approval in some regions."
    print_info "This script will try OpenAI first, then fall back to Cognitive Services."
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=11-ai-foundry"

    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Try to Create Azure OpenAI Service
    #---------------------------------------------------------------------------
    print_step "Attempting to create Azure OpenAI service..."

    local ai_kind="OpenAI"
    if ! az cognitiveservices account create \
        --name "$AI_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --kind "OpenAI" \
        --sku S0 \
        --custom-domain "$AI_ACCOUNT" \
        --output none 2>/dev/null; then

        print_warning "Azure OpenAI not available, creating Cognitive Services instead..."
        ai_kind="CognitiveServices"

        az cognitiveservices account create \
            --name "$AI_ACCOUNT" \
            --resource-group "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --kind "CognitiveServices" \
            --sku S0 \
            --yes
    fi

    echo "  ✓ ${ai_kind} account created: ${AI_ACCOUNT}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Get Keys and Endpoint
    #---------------------------------------------------------------------------
    print_step "Retrieving keys and endpoint..."

    local endpoint=$(az cognitiveservices account show \
        --name "$AI_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --query properties.endpoint \
        -o tsv 2>/dev/null || echo "N/A")

    local key1=$(az cognitiveservices account keys list \
        --name "$AI_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --query key1 \
        -o tsv 2>/dev/null || echo "N/A")

    echo "  ✓ Keys and endpoint retrieved"
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: List Available SKUs
    #---------------------------------------------------------------------------
    print_step "Available AI service kinds in ${LOCATION}:"

    az cognitiveservices account list-kinds \
        --query "[?contains(@, 'OpenAI') || contains(@, 'Cognitive') || contains(@, 'Language')]" \
        -o tsv 2>/dev/null | head -10 || echo "  (unable to list)"

    echo ""

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Azure AI Service:${NC}"
    echo "  Account:  ${AI_ACCOUNT}"
    echo "  Kind:     ${ai_kind}"
    echo "  Endpoint: ${endpoint}"
    echo "  Key:      ${key1:0:15}..."
    echo ""

    if [[ "$ai_kind" == "OpenAI" ]]; then
        echo -e "${CYAN}Deploy a Model (Azure OpenAI):${NC}"
        echo ""
        echo "  # List available models"
        echo "  az cognitiveservices account deployment list \\"
        echo "      --name ${AI_ACCOUNT} --resource-group ${RESOURCE_GROUP}"
        echo ""
        echo "  # Deploy GPT-4o-mini model"
        echo "  az cognitiveservices account deployment create \\"
        echo "      --name ${AI_ACCOUNT} --resource-group ${RESOURCE_GROUP} \\"
        echo "      --deployment-name gpt-4o-mini --model-name gpt-4o-mini \\"
        echo "      --model-version '2024-07-18' --model-format OpenAI \\"
        echo "      --sku-capacity 10 --sku-name Standard"
        echo ""
    fi

    echo -e "${CYAN}Python SDK Example:${NC}"
    echo '  from openai import AzureOpenAI'
    echo ''
    echo '  client = AzureOpenAI('
    echo "      azure_endpoint='${endpoint}',"
    echo "      api_key='${key1:0:10}...',"
    echo "      api_version='2024-02-01'"
    echo '  )'
    echo ''
    echo '  response = client.chat.completions.create('
    echo "      model='gpt-4o-mini',  # deployment name"
    echo '      messages=[{"role": "user", "content": "Hello!"}]'
    echo '  )'
    echo '  print(response.choices[0].message.content)'
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
    echo -e "${CYAN}Key Azure CLI Commands for AI Services:${NC}"
    echo ""
    echo "# Create Azure OpenAI account"
    echo "az cognitiveservices account create --name <acct> --resource-group <rg> \\"
    echo "    --location <loc> --kind OpenAI --sku S0 --custom-domain <domain>"
    echo ""
    echo "# Create Cognitive Services (multi-service)"
    echo "az cognitiveservices account create --name <acct> --resource-group <rg> \\"
    echo "    --location <loc> --kind CognitiveServices --sku S0"
    echo ""
    echo "# Get keys"
    echo "az cognitiveservices account keys list --name <acct> --resource-group <rg>"
    echo ""
    echo "# Get endpoint"
    echo "az cognitiveservices account show --name <acct> --resource-group <rg> \\"
    echo "    --query properties.endpoint"
    echo ""
    echo "# List available kinds"
    echo "az cognitiveservices account list-kinds"
    echo ""
    echo "# Deploy model (OpenAI)"
    echo "az cognitiveservices account deployment create --name <acct> \\"
    echo "    --resource-group <rg> --deployment-name <deploy> \\"
    echo "    --model-name gpt-4o-mini --model-format OpenAI"
    echo ""
    echo "# List deployments"
    echo "az cognitiveservices account deployment list --name <acct> --resource-group <rg>"
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
