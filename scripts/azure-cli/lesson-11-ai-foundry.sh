#!/bin/bash
#===============================================================================
# Lesson 11: AI Foundry - Azure CLI Deployment
#===============================================================================
# This script demonstrates how to create Azure AI Foundry resources
# using the NEW Foundry approach (March 2026):
# - Azure AI Services multi-service resource (kind: AIServices)
# - Application Insights for monitoring
# - Optional: Container Registry for hosted agents
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Contributor or Owner role on subscription
#   - Microsoft.CognitiveServices provider registered
#
# Usage:
#   ./lesson-11-ai-foundry.sh              # Deploy Foundry resources
#   ./lesson-11-ai-foundry.sh --hosted     # Deploy with hosted agents support
#   ./lesson-11-ai-foundry.sh --cleanup    # Remove all resources
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
LOCATION="${LOCATION:-northcentralus}"  # North Central US recommended for hosted agents
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-essentials-ai}"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
AI_SERVICES="ai-essentials-${UNIQUE_SUFFIX}"
LOG_WORKSPACE="log-essentials-${UNIQUE_SUFFIX}"
APP_INSIGHTS="appi-essentials-${UNIQUE_SUFFIX}"
CONTAINER_REGISTRY="cressentials${UNIQUE_SUFFIX}"
ENABLE_HOSTED_AGENTS=false

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Lesson 11: Azure AI Foundry (NEW)${NC}"
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

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

#===============================================================================
# Cleanup Function
#===============================================================================

cleanup() {
    print_header
    echo "Cleaning up AI Foundry resources..."
    echo ""

    print_step "Deleting resource group: ${RESOURCE_GROUP}"
    az group delete \
        --name "$RESOURCE_GROUP" \
        --yes \
        --no-wait

    echo ""
    print_success "Cleanup initiated (runs in background)"
    echo ""
    print_warning "AI Services accounts are soft-deleted for 48 hours."
    echo "To permanently delete (purge), use:"
    echo "  az cognitiveservices account purge --name ${AI_SERVICES} --location ${LOCATION}"
}

#===============================================================================
# Deploy Function
#===============================================================================

deploy() {
    print_header

    print_info "Location: ${LOCATION}"
    print_info "Resource Group: ${RESOURCE_GROUP}"
    print_info "AI Services: ${AI_SERVICES}"
    print_info "Hosted Agents: ${ENABLE_HOSTED_AGENTS}"
    echo ""
    print_warning "North Central US is recommended for hosted agents preview."
    echo ""

    #---------------------------------------------------------------------------
    # Step 1: Register Resource Provider
    #---------------------------------------------------------------------------
    print_step "Checking Microsoft.CognitiveServices provider..."

    local provider_state=$(az provider show --namespace Microsoft.CognitiveServices --query "registrationState" -o tsv 2>/dev/null || echo "NotRegistered")

    if [[ "$provider_state" != "Registered" ]]; then
        print_info "Registering Microsoft.CognitiveServices provider..."
        az provider register --namespace Microsoft.CognitiveServices
        echo "  Waiting for registration (this may take a minute)..."
        az provider show --namespace Microsoft.CognitiveServices --query "registrationState" -o tsv --wait
    fi
    print_success "Provider registered"
    echo ""

    #---------------------------------------------------------------------------
    # Step 2: Create Resource Group
    #---------------------------------------------------------------------------
    print_step "Creating resource group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=11-ai-foundry" \
        --output none

    print_success "Resource group created: ${RESOURCE_GROUP}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 3: Create Log Analytics Workspace
    #---------------------------------------------------------------------------
    print_step "Creating Log Analytics workspace..."

    az monitor log-analytics workspace create \
        --resource-group "$RESOURCE_GROUP" \
        --workspace-name "$LOG_WORKSPACE" \
        --location "$LOCATION" \
        --output none

    local log_workspace_id=$(az monitor log-analytics workspace show \
        --resource-group "$RESOURCE_GROUP" \
        --workspace-name "$LOG_WORKSPACE" \
        --query id -o tsv)

    print_success "Log Analytics workspace created: ${LOG_WORKSPACE}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 4: Create Application Insights
    #---------------------------------------------------------------------------
    print_step "Creating Application Insights..."

    az monitor app-insights component create \
        --app "$APP_INSIGHTS" \
        --location "$LOCATION" \
        --resource-group "$RESOURCE_GROUP" \
        --workspace "$log_workspace_id" \
        --output none

    local app_insights_key=$(az monitor app-insights component show \
        --app "$APP_INSIGHTS" \
        --resource-group "$RESOURCE_GROUP" \
        --query connectionString -o tsv)

    print_success "Application Insights created: ${APP_INSIGHTS}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 5: Create Azure AI Services (Foundry Resource)
    #---------------------------------------------------------------------------
    print_step "Creating Azure AI Services (Foundry resource)..."

    az cognitiveservices account create \
        --name "$AI_SERVICES" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --kind "AIServices" \
        --sku "S0" \
        --custom-domain "$AI_SERVICES" \
        --yes \
        --output none

    local endpoint=$(az cognitiveservices account show \
        --name "$AI_SERVICES" \
        --resource-group "$RESOURCE_GROUP" \
        --query properties.endpoint -o tsv)

    local key1=$(az cognitiveservices account keys list \
        --name "$AI_SERVICES" \
        --resource-group "$RESOURCE_GROUP" \
        --query key1 -o tsv)

    print_success "AI Services created: ${AI_SERVICES}"
    echo ""

    #---------------------------------------------------------------------------
    # Step 6: Create Container Registry (if hosted agents enabled)
    #---------------------------------------------------------------------------
    if [[ "$ENABLE_HOSTED_AGENTS" == "true" ]]; then
        print_step "Creating Container Registry for hosted agents..."

        az acr create \
            --name "$CONTAINER_REGISTRY" \
            --resource-group "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --sku Basic \
            --admin-enabled true \
            --output none

        local acr_login_server=$(az acr show \
            --name "$CONTAINER_REGISTRY" \
            --resource-group "$RESOURCE_GROUP" \
            --query loginServer -o tsv)

        print_success "Container Registry created: ${acr_login_server}"
        echo ""
    fi

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Azure AI Foundry Deployment Complete${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Azure AI Services (Foundry Resource):${NC}"
    echo "  Name:     ${AI_SERVICES}"
    echo "  Kind:     AIServices (multi-service)"
    echo "  Endpoint: ${endpoint}"
    echo "  Key:      ${key1:0:15}..."
    echo ""
    echo -e "${CYAN}Monitoring:${NC}"
    echo "  App Insights: ${APP_INSIGHTS}"
    echo "  Log Analytics: ${LOG_WORKSPACE}"
    echo ""

    if [[ "$ENABLE_HOSTED_AGENTS" == "true" ]]; then
        echo -e "${CYAN}Hosted Agents:${NC}"
        echo "  Registry: ${acr_login_server}"
        echo ""
    fi

    echo -e "${CYAN}Deploy a Model:${NC}"
    echo ""
    echo "  # List available models"
    echo "  az cognitiveservices model list --location ${LOCATION} -o table"
    echo ""
    echo "  # Deploy GPT-4o-mini model"
    echo "  az cognitiveservices account deployment create \\"
    echo "      --name ${AI_SERVICES} --resource-group ${RESOURCE_GROUP} \\"
    echo "      --deployment-name gpt-4o-mini --model-name gpt-4o-mini \\"
    echo "      --model-version '2024-07-18' --model-format OpenAI \\"
    echo "      --sku-capacity 10 --sku-name Standard"
    echo ""
    echo -e "${CYAN}Python SDK Example:${NC}"
    echo '  from openai import AzureOpenAI'
    echo ''
    echo '  client = AzureOpenAI('
    echo "      azure_endpoint='${endpoint}',"
    echo "      api_key='<your-key>',"
    echo "      api_version='2024-10-01-preview'"
    echo '  )'
    echo ''
    echo '  response = client.chat.completions.create('
    echo "      model='gpt-4o-mini',  # deployment name"
    echo '      messages=[{"role": "user", "content": "Hello!"}]'
    echo '  )'
    echo '  print(response.choices[0].message.content)'
    echo ""
    echo -e "${CYAN}azd Alternative (Recommended):${NC}"
    echo "  # For a complete Foundry project with hosted agents:"
    echo "  mkdir my-foundry-project && cd my-foundry-project"
    echo "  azd init -t https://github.com/Azure-Samples/azd-ai-starter-basic"
    echo "  azd env set ENABLE_HOSTED_AGENTS true"
    echo "  azd provision"
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
    echo -e "${CYAN}Key Azure CLI Commands for AI Foundry:${NC}"
    echo ""
    echo "# Create Azure AI Services (Foundry resource)"
    echo "az cognitiveservices account create --name <name> --resource-group <rg> \\"
    echo "    --location <loc> --kind AIServices --sku S0 --custom-domain <domain>"
    echo ""
    echo "# Get endpoint and keys"
    echo "az cognitiveservices account show --name <name> --resource-group <rg> \\"
    echo "    --query properties.endpoint"
    echo "az cognitiveservices account keys list --name <name> --resource-group <rg>"
    echo ""
    echo "# List available models in a region"
    echo "az cognitiveservices model list --location <loc> -o table"
    echo ""
    echo "# Deploy a model"
    echo "az cognitiveservices account deployment create --name <acct> \\"
    echo "    --resource-group <rg> --deployment-name <deploy> \\"
    echo "    --model-name gpt-4o-mini --model-format OpenAI \\"
    echo "    --sku-capacity 10 --sku-name Standard"
    echo ""
    echo "# List deployments"
    echo "az cognitiveservices account deployment list --name <acct> --resource-group <rg>"
    echo ""
    echo "# Purge soft-deleted account"
    echo "az cognitiveservices account purge --name <name> --location <loc>"
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
    --hosted)
        ENABLE_HOSTED_AGENTS=true
        deploy
        ;;
    *)
        deploy
        ;;
esac
