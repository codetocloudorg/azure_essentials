#!/bin/bash
#===============================================================================
# Azure Essentials - Deployment Validation Script
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# PURPOSE:
#   Validates that lesson deployments completed successfully by checking
#   for expected Azure resources. Use this during live training to verify
#   deployments are working correctly before moving to the next lesson.
#
# HOW IT WORKS:
#   This script uses Azure CLI (az) to query your subscription and verify
#   that the expected resources exist. Each lesson has its own validation
#   function that checks for specific resource types.
#
# AZURE CLI QUERIES USED:
#   - az group list          : Find resource groups by pattern
#   - az resource list       : List resources in a resource group
#   - az storage account list: Verify storage accounts
#   - az network vnet list   : Verify virtual networks
#   - az vm list             : Verify virtual machines
#   - az aks list            : Verify Kubernetes clusters
#
# WHY VALIDATION MATTERS:
#   - Confirms Bicep deployments succeeded
#   - Catches partial failures (some resources created, others failed)
#   - Helps troubleshoot deployment issues
#   - Provides confidence before moving to next lesson
#
# USAGE:
#   ./test-deployment.sh                    # Test all lessons
#   ./test-deployment.sh 03                 # Test specific lesson
#   ./test-deployment.sh --env myenv 03     # Test with custom env name
#
# REQUIREMENTS:
#   - Azure CLI installed and logged in
#   - Resources deployed via deploy.sh or azure-cli scripts
#
# WHAT EACH LESSON DEPLOYS:
#   Lesson 02: Management Groups (tenant-level hierarchy)
#   Lesson 03: Storage Services (Blob, Files, Queues, Tables)
#   Lesson 04: Networking (VNet, Subnets, NSGs, Bastion)
#   Lesson 05: Compute - Windows (Windows VM, IIS, ASP.NET)
#   Lesson 06: Compute - Linux (Linux VM, MicroK8s)
#   Lesson 07: Container Services (ACR, ACI, AKS)
#   Lesson 08: Serverless (Azure Functions, Logic Apps)
#   Lesson 09: Database Services (Cosmos DB, SQL)
#   Lesson 11: AI Foundry (Azure OpenAI, AI Hub)
#
#===============================================================================

# Don't exit on error - we need to continue validating even if some fail
# set -e

#===============================================================================
# CONFIGURATION
#===============================================================================
# The ENV_NAME is used to find resource groups created by azd.
# azd names resources using the pattern: rg-<env-name>-<lesson>
#
# You can override this with:
#   export AZURE_ENV_NAME=myenv
# Or use the --env flag:
#   ./test-deployment.sh --env myenv
#===============================================================================

# Default environment name pattern (used to find resource groups)
ENV_NAME="${AZURE_ENV_NAME:-azlearn}"

#===============================================================================
# TERMINAL COLORS - Visual feedback for validation results
#===============================================================================
# Color coding makes it easy to scan results during live training:
#   GREEN  = Resource found, validation passed
#   RED    = Resource missing, validation failed
#   YELLOW = Warning (optional resource missing)
#   BLUE   = Section headers
#   CYAN   = Informational details
#===============================================================================
RED='\033[0;31m'      # Errors - resource missing or failed
GREEN='\033[0;32m'    # Success - resource found and valid
YELLOW='\033[1;33m'   # Warnings - optional items
BLUE='\033[0;34m'     # Section headers
CYAN='\033[0;36m'     # Details and resource names
MAGENTA='\033[0;35m'  # Highlights
BOLD='\033[1m'        # Emphasis
DIM='\033[2m'         # De-emphasis
NC='\033[0m'          # Reset color

#===============================================================================
# HELPER FUNCTIONS - Consistent output formatting
#===============================================================================
# These functions provide consistent visual output across all validations.
# Reusable patterns like this are common in production scripts.
#===============================================================================

# Print a major section header
print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${BOLD}$1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Print a sub-section header
print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Success message with checkmark
print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

# Error message with X
print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

# Warning message with exclamation
print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

# Info message with bullet
print_info() {
    echo -e "  ${CYAN}●${NC} $1"
}

# Detail message (indented, used for sub-items)
print_detail() {
    echo -e "    ${DIM}└─${NC} $1"
}

#===============================================================================
# AZURE CLI HELPER FUNCTIONS
#===============================================================================
# These functions wrap Azure CLI commands for common validation tasks.
# They demonstrate JMESPath queries for filtering Azure resources.
#
# KEY CONCEPT: JMESPath Queries
#   Azure CLI uses JMESPath for querying JSON output.
#   Examples:
#     --query "[0].name"              # Get name of first item
#     --query "[?name=='foo']"        # Filter by name
#     --query "length(@)"             # Count items
#     --query "[].{name:name,sku:sku.name}" # Select specific fields
#===============================================================================

# Find resource groups matching a pattern
find_resource_groups() {
    local pattern="$1"
    az group list --query "[?contains(name, '${pattern}')].name" -o tsv 2>/dev/null
}

# Check if a specific resource type exists in a resource group
# Uses JMESPath to filter by resource type and name pattern
check_resource() {
    local rg="$1"
    local type="$2"
    local name_pattern="$3"

    local count=$(az resource list \
        --resource-group "$rg" \
        --resource-type "$type" \
        --query "length([?contains(name, '${name_pattern}')])" \
        -o tsv 2>/dev/null)

    [[ "$count" -gt 0 ]]
}

#===============================================================================
# LESSON VALIDATION FUNCTIONS
#===============================================================================
# Each lesson has a dedicated validation function.
# These demonstrate different Azure resource types and CLI commands.
#===============================================================================

#-------------------------------------------------------------------------------
# Lesson 02: Management Groups
#-------------------------------------------------------------------------------
# Management Groups are tenant-level (not subscription-level) resources.
# They provide hierarchical organization for subscriptions.
#
# BICEP CONCEPTS DEMONSTRATED:
#   - targetScope = 'managementGroup' or 'tenant'
#   - Hierarchical resource relationships
#
# AZURE CLI:
#   az account management-group list
#   az account management-group show -n <name>
#-------------------------------------------------------------------------------
validate_lesson_02() {
    print_section "🏢 Lesson 02: Management Groups"
    echo -e "  ${CYAN}Checking for management group hierarchy...${NC}"
    echo -e "  ${CYAN}(Management Groups organize subscriptions at the tenant level)${NC}"
    echo ""

    # Management Groups are tenant-level resources
    local expected_groups=("mg-essentials-root" "mg-essentials-production" "mg-essentials-development" "mg-essentials-sandbox")
    local mg_count=0
    local found_groups=""

    for mg in "${expected_groups[@]}"; do
        if az account management-group show -n "$mg" -o tsv --query name 2>/dev/null >/dev/null; then
            ((mg_count++))
            found_groups="$found_groups$mg\n"
        fi
    done

    if [[ "$mg_count" -eq 0 ]]; then
        print_error "No Management Groups found"
        print_detail "Expected pattern: mg-essentials-*"
        return 1
    fi

    print_info "Found ${mg_count} Management Group(s)"

    # List the management groups we found
    print_success "Management Groups:"
    for mg in "${expected_groups[@]}"; do
        local display=$(az account management-group show -n "$mg" --query displayName -o tsv 2>/dev/null)
        if [[ -n "$display" ]]; then
            print_detail "$mg ($display)"
        fi
    done

    echo ""
    print_success "Lesson 02 validation PASSED"
    return 0
}

#-------------------------------------------------------------------------------
# Lesson 03: Storage Services
#-------------------------------------------------------------------------------
# Azure Storage is one of the most fundamental Azure services.
# It provides four types of storage:
#   - Blobs: Unstructured data (files, images, videos)
#   - Files: SMB file shares (lift-and-shift scenarios)
#   - Queues: Message queuing for async processing
#   - Tables: NoSQL key-value storage
#
# BICEP CONCEPTS DEMONSTRATED:
#   - Resource naming with uniqueString()
#   - Storage account SKU tiers (Standard_LRS, Standard_GRS)
#   - Nested resources (containers within storage accounts)
#
# AZURE CLI:
#   az storage account list -g <rg>
#   az storage container list --account-name <name>
#-------------------------------------------------------------------------------
validate_lesson_03() {
    print_section "📦 Lesson 03: Storage Services"
    echo -e "  ${CYAN}Verifying Azure Storage resources...${NC}"
    echo -e "  ${CYAN}(Storage Accounts provide Blob, File, Queue, and Table storage)${NC}"
    echo ""

    # Look for resource groups matching various naming patterns
    local rg=$(az group list --query "[?contains(name, 'storage') || contains(name, 'lesson03') || contains(name, 'lesson-03')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 03"
        print_detail "Expected pattern: *lesson03* or *storage*"
        return 1
    fi

    print_info "Resource Group: ${rg}"
    local passed=0
    local failed=0

    # Check storage account
    if check_resource "$rg" "Microsoft.Storage/storageAccounts" ""; then
        local storage_name=$(az storage account list -g "$rg" --query "[0].name" -o tsv 2>/dev/null)
        print_success "Storage Account: ${storage_name}"

        # Check containers
        local key=$(az storage account keys list --account-name "$storage_name" -g "$rg" --query "[0].value" -o tsv 2>/dev/null)
        local containers=$(az storage container list --account-name "$storage_name" --account-key "$key" --query "length(@)" -o tsv 2>/dev/null)

        if [[ "$containers" -gt 0 ]]; then
            print_success "Blob Containers: ${containers} container(s)"
        else
            print_warning "No blob containers found"
        fi
        ((passed++))
    else
        print_error "Storage Account not found"
        ((failed++))
    fi

    echo ""
    if [[ $failed -eq 0 ]]; then
        print_success "Lesson 03 validation PASSED"
        return 0
    else
        print_error "Lesson 03 validation FAILED (${failed} issues)"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Lesson 04: Networking
#-------------------------------------------------------------------------------
# Azure Networking is the foundation for all cloud architectures.
# Key components:
#   - Virtual Network (VNet): Isolated network in Azure
#   - Subnets: Segments within a VNet for resource organization
#   - NSG: Network Security Groups (firewall rules)
#   - Azure Bastion: Secure RDP/SSH without public IPs
#
# BICEP CONCEPTS DEMONSTRATED:
#   - dependsOn for resource ordering
#   - Resource properties and child resources
#   - Security rules as nested resources
#
# NETWORKING BEST PRACTICES:
#   - Use address spaces that don't overlap with on-premises
#   - Segment workloads into subnets (web, app, data tiers)
#   - Apply NSG rules at subnet level
#
# AZURE CLI:
#   az network vnet list -g <rg>
#   az network nsg list -g <rg>
#   az network nsg rule list -g <rg> --nsg-name <name>
#-------------------------------------------------------------------------------
validate_lesson_04() {
    print_section "🌐 Lesson 04: Networking Services"
    echo -e "  ${CYAN}Verifying Virtual Network infrastructure...${NC}"
    echo -e "  ${CYAN}(VNets provide isolated networking for Azure resources)${NC}"
    echo ""

    local rg=$(az group list --query "[?contains(name, 'networking') || contains(name, 'lesson04') || contains(name, 'lesson-04')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 04"
        return 1
    fi

    print_info "Resource Group: ${rg}"
    local passed=0
    local failed=0

    # Check VNet
    if check_resource "$rg" "Microsoft.Network/virtualNetworks" ""; then
        local vnet_name=$(az network vnet list -g "$rg" --query "[0].name" -o tsv 2>/dev/null)
        local address_space=$(az network vnet show -g "$rg" -n "$vnet_name" --query "addressSpace.addressPrefixes[0]" -o tsv 2>/dev/null)
        print_success "Virtual Network: ${vnet_name} (${address_space})"

        # Check subnets
        local subnets=$(az network vnet subnet list -g "$rg" --vnet-name "$vnet_name" --query "length(@)" -o tsv 2>/dev/null)
        print_success "Subnets: ${subnets} subnet(s)"
        ((passed++))
    else
        print_error "Virtual Network not found"
        ((failed++))
    fi

    # Check NSG
    if check_resource "$rg" "Microsoft.Network/networkSecurityGroups" ""; then
        local nsg_count=$(az network nsg list -g "$rg" --query "length(@)" -o tsv 2>/dev/null)
        print_success "Network Security Groups: ${nsg_count}"
        ((passed++))
    else
        print_warning "No NSG found (may be expected)"
    fi

    echo ""
    if [[ $failed -eq 0 ]]; then
        print_success "Lesson 04 validation PASSED"
        return 0
    else
        print_error "Lesson 04 validation FAILED"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Lesson 05: Windows Compute
#-------------------------------------------------------------------------------
# Azure Virtual Machines provide IaaS compute resources.
# This lesson focuses on Windows Server workloads.
#
# KEY CONCEPTS:
#   - VM Sizes: Different CPU/RAM configurations (e.g., Standard_D2s_v3)
#   - VM Images: Pre-built OS images (Windows Server, SQL Server)
#   - Disks: OS disk and optional data disks (Standard/Premium SSD)
#   - Extensions: Post-deployment configuration (IIS, custom scripts)
#
# BICEP CONCEPTS DEMONSTRATED:
#   - VM resource with imageReference
#   - VM Extensions for IIS installation
#   - Secure parameter handling for passwords
#   - dependsOn chains (VM → NIC → VNet)
#
# AZURE CLI:
#   az vm list -g <rg>
#   az vm get-instance-view -g <rg> -n <name>  # Get power state
#   az vm list-ip-addresses -g <rg> -n <name>  # Get public IP
#-------------------------------------------------------------------------------
validate_lesson_05() {
    print_section "🖥️ Lesson 05: Windows Compute"
    echo -e "  ${CYAN}Verifying Windows VM and web server resources...${NC}"
    echo -e "  ${CYAN}(VMs run Windows Server with IIS for web hosting)${NC}"
    echo ""

    local rg=$(az group list --query "[?contains(name, 'compute') || contains(name, 'windows') || contains(name, 'lesson05') || contains(name, 'lesson-05')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 05"
        return 1
    fi

    print_info "Resource Group: ${rg}"
    local passed=0
    local failed=0

    # Check Windows VM
    local vm_name=$(az vm list -g "$rg" --query "[?storageProfile.osDisk.osType=='Windows'].name | [0]" -o tsv 2>/dev/null)
    if [[ -n "$vm_name" ]]; then
        local vm_size=$(az vm show -g "$rg" -n "$vm_name" --query "hardwareProfile.vmSize" -o tsv 2>/dev/null)
        local power_state=$(az vm get-instance-view -g "$rg" -n "$vm_name" --query "instanceView.statuses[1].displayStatus" -o tsv 2>/dev/null)
        print_success "Windows VM: ${vm_name} (${vm_size})"
        print_detail "Power State: ${power_state}"

        # Get public IP
        local pip=$(az vm list-ip-addresses -g "$rg" -n "$vm_name" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv 2>/dev/null)
        if [[ -n "$pip" ]]; then
            print_detail "Public IP: ${pip}"
        fi
        ((passed++))
    else
        print_warning "Windows VM not found (may use App Service only)"
    fi

    # Check App Service
    local app_name=$(az webapp list -g "$rg" --query "[0].name" -o tsv 2>/dev/null)
    if [[ -n "$app_name" ]]; then
        local app_url=$(az webapp show -g "$rg" -n "$app_name" --query "defaultHostName" -o tsv 2>/dev/null)
        print_success "App Service: ${app_name}"
        print_detail "URL: https://${app_url}"
        ((passed++))
    else
        print_warning "App Service not found"
    fi

    echo ""
    if [[ $passed -gt 0 ]]; then
        print_success "Lesson 05 validation PASSED"
        return 0
    else
        print_error "Lesson 05 validation FAILED"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Lesson 06: Linux & Kubernetes
#-------------------------------------------------------------------------------
# Linux VMs are common for open-source workloads and containers.
# This lesson demonstrates MicroK8s - a lightweight Kubernetes distribution.
#
# KEY CONCEPTS:
#   - Linux images (Ubuntu, RHEL, Debian)
#   - SSH key authentication (more secure than passwords)
#   - Cloud-init for automated configuration
#   - MicroK8s: Single-node Kubernetes for learning
#
# BICEP CONCEPTS DEMONSTRATED:
#   - Linux-specific VM configuration
#   - SSH public key deployment
#   - Custom script extensions for cloud-init
#
# AZURE CLI:
#   az vm list -g <rg> --query "[?osType=='Linux']"
#   az vm run-command invoke  # Run commands inside VM
#-------------------------------------------------------------------------------
validate_lesson_06() {
    print_section "🐧 Lesson 06: Linux & Kubernetes"
    echo -e "  ${CYAN}Verifying Linux VM with MicroK8s...${NC}"
    echo -e "  ${CYAN}(MicroK8s provides a lightweight Kubernetes environment)${NC}"
    echo ""

    local rg=$(az group list --query "[?contains(name, 'linux') || contains(name, 'k8s') || contains(name, 'lesson06') || contains(name, 'lesson-06')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 06"
        return 1
    fi

    print_info "Resource Group: ${rg}"

    # Check Linux VM
    local vm_name=$(az vm list -g "$rg" --query "[?storageProfile.osDisk.osType=='Linux'].name | [0]" -o tsv 2>/dev/null)
    if [[ -n "$vm_name" ]]; then
        local vm_size=$(az vm show -g "$rg" -n "$vm_name" --query "hardwareProfile.vmSize" -o tsv 2>/dev/null)
        local image=$(az vm show -g "$rg" -n "$vm_name" --query "storageProfile.imageReference.offer" -o tsv 2>/dev/null)
        print_success "Linux VM: ${vm_name} (${vm_size})"
        print_detail "Image: ${image}"

        # Get public IP for SSH
        local pip=$(az vm list-ip-addresses -g "$rg" -n "$vm_name" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv 2>/dev/null)
        if [[ -n "$pip" ]]; then
            print_detail "SSH: ssh azureuser@${pip}"
        fi

        echo ""
        print_success "Lesson 06 validation PASSED"
        return 0
    else
        print_error "Linux VM not found"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Lesson 07: Container Services
#-------------------------------------------------------------------------------
# Azure provides multiple container hosting options:
#   - ACR (Azure Container Registry): Private Docker image storage
#   - ACI (Azure Container Instances): Serverless container hosting
#   - AKS (Azure Kubernetes Service): Managed Kubernetes clusters
#
# KEY CONCEPTS:
#   - Container images are stored in registries (ACR)
#   - ACI is perfect for simple, single-container workloads
#   - AKS is for production orchestration with multiple containers
#
# BICEP CONCEPTS DEMONSTRATED:
#   - ACR resource with admin credentials
#   - ACI container group with environment variables
#   - ACR integration with ACI/AKS (pull secrets)
#
# AZURE CLI:
#   az acr list -g <rg>
#   az acr repository list -n <acr-name>
#   az container list -g <rg>
#   az aks list -g <rg>
#-------------------------------------------------------------------------------
validate_lesson_07() {
    print_section "🐳 Lesson 07: Container Services"
    echo -e "  ${CYAN}Verifying container infrastructure...${NC}"
    echo -e "  ${CYAN}(ACR stores images, ACI/AKS run containers)${NC}"
    echo ""

    local rg=$(az group list --query "[?contains(name, 'container') || contains(name, 'lesson07') || contains(name, 'lesson-07')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 07"
        return 1
    fi

    print_info "Resource Group: ${rg}"

    # Check ACR
    local acr_name=$(az acr list -g "$rg" --query "[0].name" -o tsv 2>/dev/null)
    if [[ -n "$acr_name" ]]; then
        local login_server=$(az acr show -g "$rg" -n "$acr_name" --query "loginServer" -o tsv 2>/dev/null)
        local sku=$(az acr show -g "$rg" -n "$acr_name" --query "sku.name" -o tsv 2>/dev/null)
        print_success "Container Registry: ${acr_name}"
        print_detail "Login Server: ${login_server}"
        print_detail "SKU: ${sku}"

        # Check for images
        local repo_count=$(az acr repository list -n "$acr_name" --query "length(@)" -o tsv 2>/dev/null || echo "0")
        print_detail "Repositories: ${repo_count}"

        echo ""
        print_success "Lesson 07 validation PASSED"
        return 0
    else
        print_error "Container Registry not found"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Lesson 08: Serverless
#-------------------------------------------------------------------------------
# Serverless computing eliminates server management:
#   - Azure Functions: Event-driven code execution
#   - Logic Apps: Visual workflow automation
#   - Event Grid: Event routing and delivery
#
# KEY CONCEPTS:
#   - Consumption Plan: Pay only for execution time
#   - Triggers: HTTP, Timer, Queue, Blob, etc.
#   - Bindings: Declarative input/output connections
#
# BICEP CONCEPTS DEMONSTRATED:
#   - Function App with consumption plan
#   - Storage account for function state
#   - App settings for configuration
#
# AZURE CLI:
#   az functionapp list -g <rg>
#   az functionapp function list -g <rg> -n <app>
#   az functionapp config appsettings list
#-------------------------------------------------------------------------------
validate_lesson_08() {
    print_section "⚡ Lesson 08: Serverless Services"
    echo -e "  ${CYAN}Verifying Azure Functions deployment...${NC}"
    echo -e "  ${CYAN}(Functions provide event-driven, pay-per-execution compute)${NC}"
    echo ""

    local rg=$(az group list --query "[?contains(name, 'serverless') || contains(name, 'function') || contains(name, 'lesson08') || contains(name, 'lesson-08')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 08"
        return 1
    fi

    print_info "Resource Group: ${rg}"

    # Check Function App
    local func_name=$(az functionapp list -g "$rg" --query "[0].name" -o tsv 2>/dev/null)
    if [[ -n "$func_name" ]]; then
        local func_url=$(az functionapp show -g "$rg" -n "$func_name" --query "defaultHostName" -o tsv 2>/dev/null)
        local runtime=$(az functionapp show -g "$rg" -n "$func_name" --query "siteConfig.linuxFxVersion" -o tsv 2>/dev/null)
        print_success "Function App: ${func_name}"
        print_detail "URL: https://${func_url}"
        print_detail "Runtime: ${runtime}"

        echo ""
        print_success "Lesson 08 validation PASSED"
        return 0
    else
        print_error "Function App not found"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Lesson 09: Database Services
#-------------------------------------------------------------------------------
# Azure provides fully managed database options:
#   - Cosmos DB: Multi-model, globally distributed NoSQL
#   - Azure SQL: Managed SQL Server
#   - PostgreSQL/MySQL: Managed open-source databases
#
# KEY CONCEPTS:
#   - RU/s (Request Units): Cosmos DB throughput measure
#   - Consistency Levels: Trade-off between consistency and latency
#   - Partition Keys: Data distribution strategy
#
# BICEP CONCEPTS DEMONSTRATED:
#   - Cosmos DB account with multiple regions
#   - Database and container as child resources
#   - Throughput configuration
#
# AZURE CLI:
#   az cosmosdb list -g <rg>
#   az cosmosdb sql database list --account-name <name>
#   az cosmosdb keys list --name <name>
#-------------------------------------------------------------------------------
validate_lesson_09() {
    print_section "🗄️ Lesson 09: Database Services"
    echo -e "  ${CYAN}Verifying Cosmos DB deployment...${NC}"
    echo -e "  ${CYAN}(Cosmos DB provides globally distributed NoSQL storage)${NC}"
    echo ""

    local rg=$(az group list --query "[?contains(name, 'database') || contains(name, 'cosmos') || contains(name, 'lesson09') || contains(name, 'lesson-09')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 09"
        return 1
    fi

    print_info "Resource Group: ${rg}"

    # Check Cosmos DB
    local cosmos_name=$(az cosmosdb list -g "$rg" --query "[0].name" -o tsv 2>/dev/null)
    if [[ -n "$cosmos_name" ]]; then
        local endpoint=$(az cosmosdb show -g "$rg" -n "$cosmos_name" --query "documentEndpoint" -o tsv 2>/dev/null)
        local consistency=$(az cosmosdb show -g "$rg" -n "$cosmos_name" --query "consistencyPolicy.defaultConsistencyLevel" -o tsv 2>/dev/null)
        print_success "Cosmos DB Account: ${cosmos_name}"
        print_detail "Endpoint: ${endpoint}"
        print_detail "Consistency: ${consistency}"

        echo ""
        print_success "Lesson 09 validation PASSED"
        return 0
    else
        print_error "Cosmos DB not found"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Lesson 11: AI Foundry
#-------------------------------------------------------------------------------
# Azure AI Foundry provides a unified platform for AI development:
#   - Azure OpenAI: GPT models, embeddings, DALL-E
#   - AI Hub: Central management for AI projects
#   - Cognitive Services: Pre-built AI APIs
#
# KEY CONCEPTS:
#   - Model Deployments: Deploy specific models (gpt-4, gpt-35-turbo)
#   - Tokens: AI usage is measured in tokens
#   - Prompt Engineering: Crafting effective prompts
#
# BICEP CONCEPTS DEMONSTRATED:
#   - Cognitive Services account resource
#   - Deployment of AI models
#   - Key management for API access
#
# AZURE CLI:
#   az cognitiveservices account list -g <rg>
#   az cognitiveservices account deployment list
#   az cognitiveservices account keys list
#-------------------------------------------------------------------------------
validate_lesson_11() {
    print_section "🤖 Lesson 11: Azure AI Foundry"
    echo -e "  ${CYAN}Verifying AI and Machine Learning resources...${NC}"
    echo -e "  ${CYAN}(AI Foundry provides Azure OpenAI and ML capabilities)${NC}"
    echo ""

    # Be specific with '-ai' suffix to avoid matching 'containers' which contains 'ai'
    local rg=$(az group list --query "[?contains(name, '-ai') || contains(name, 'foundry') || contains(name, 'lesson11') || contains(name, 'lesson-11')].name" -o tsv 2>/dev/null | head -1)

    if [[ -z "$rg" ]]; then
        print_error "Resource group not found for Lesson 11"
        return 1
    fi

    print_info "Resource Group: ${rg}"

    # Check AI/ML workspace or Cognitive Services
    local ai_count=$(az resource list -g "$rg" --query "length([?contains(type, 'CognitiveServices') || contains(type, 'MachineLearning')])" -o tsv 2>/dev/null)

    if [[ "$ai_count" -gt 0 ]]; then
        print_success "AI/ML Resources: ${ai_count} found"

        # List resources
        az resource list -g "$rg" \
            --query "[?contains(type, 'CognitiveServices') || contains(type, 'MachineLearning')].{Name:name, Type:type}" \
            -o table 2>/dev/null | tail -n +3 | while read line; do
            print_detail "$line"
        done

        echo ""
        print_success "Lesson 11 validation PASSED"
        return 0
    else
        print_error "No AI/ML resources found"
        return 1
    fi
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

# Print banner
print_header "☁️  Azure Essentials - Deployment Validation"
echo ""
echo -e "  ${CYAN}Code to Cloud${NC} | Validating lesson deployments"
echo -e "  ${DIM}Environment pattern: *${ENV_NAME}*${NC}"

# Parse arguments
LESSON=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --env|-e)
            ENV_NAME="$2"
            shift 2
            ;;
        [0-9]*)
            # Zero-pad lesson number to 2 digits (3 -> 03)
            LESSON=$(printf "%02d" "$1")
            shift
            ;;
        --help|-h)
            echo ""
            echo "Usage: $0 [--env <name>] [lesson_number]"
            echo ""
            echo "Examples:"
            echo "  $0                    # Validate all lessons"
            echo "  $0 03                 # Validate lesson 03 only"
            echo "  $0 --env myenv 05     # Validate lesson 05 with custom env"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Check Azure login
print_section "🔐 Checking Azure Connection"
if az account show &>/dev/null; then
    local_account=$(az account show --query name -o tsv)
    print_success "Logged in to: ${local_account}"
else
    print_error "Not logged in to Azure. Run: az login"
    exit 1
fi

# Show discovered resource groups
print_section "📂 Discovering Resources"

# First check for Management Groups (Lesson 02 - tenant-level resources)
# Note: az account management-group list doesn't show children, so check each directly
mg_list=""
for mg in "mg-essentials-root" "mg-essentials-production" "mg-essentials-development" "mg-essentials-sandbox"; do
    if az account management-group show -n "$mg" -o tsv --query name 2>/dev/null >/dev/null; then
        mg_list="$mg_list$mg\n"
    fi
done
mg_list=$(echo -e "$mg_list" | sed '/^$/d')

# Then check for resource groups (look for multiple patterns to catch any env names)
rg_list=$(find_resource_groups "$ENV_NAME")
essentials_rg_list=$(find_resource_groups "essentials")
lesson_rg_list=$(find_resource_groups "lesson")
# Merge and dedupe
all_rg_list=$(echo -e "${rg_list}\n${essentials_rg_list}\n${lesson_rg_list}" | sort -u | sed '/^$/d')
rg_list="$all_rg_list"

# Handle case where neither exist
if [[ -z "$rg_list" ]] && [[ -z "$mg_list" ]]; then
    print_warning "No resources found matching patterns"
    print_info "Resource groups: *${ENV_NAME}* or *essentials*"
    print_info "Management groups: mg-essentials-*"
    print_info "Tip: Set environment name with --env flag or AZURE_ENV_NAME variable"
    exit 1
fi

# Show what we found
if [[ -n "$mg_list" ]]; then
    echo -e "  Found Management Groups (Lesson 02):"
    echo "$mg_list" | while read mg; do
        print_info "$mg"
    done
fi

if [[ -n "$rg_list" ]]; then
    echo -e "  Found Resource Groups:"
    echo "$rg_list" | while read rg; do
        print_info "$rg"
    done
fi

# Run validations
TOTAL_PASSED=0
TOTAL_FAILED=0

run_validation() {
    local lesson=$1
    case $lesson in
        02) if validate_lesson_02; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        03) if validate_lesson_03; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        04) if validate_lesson_04; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        05) if validate_lesson_05; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        06) if validate_lesson_06; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        07) if validate_lesson_07; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        08) if validate_lesson_08; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        09) if validate_lesson_09; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        11) if validate_lesson_11; then TOTAL_PASSED=$((TOTAL_PASSED+1)); else TOTAL_FAILED=$((TOTAL_FAILED+1)); fi ;;
        *) print_warning "Unknown lesson: $lesson" ;;
    esac
}

if [[ -n "$LESSON" ]]; then
    # Validate specific lesson
    run_validation "$LESSON"
else
    # Check for Management Groups first (Lesson 02) - already discovered above
    if [[ -n "$mg_list" ]]; then
        run_validation "02"
    fi

    # Validate all lessons that have resource groups
    # Check for both azd naming (lesson03) and azure-cli naming (storage, networking, etc.)

    # Lesson 03: Storage
    if echo "$rg_list" | grep -qiE "lesson.?03|storage"; then
        run_validation "03"
    fi

    # Lesson 04: Networking
    if echo "$rg_list" | grep -qiE "lesson.?04|networking"; then
        run_validation "04"
    fi

    # Lesson 05: Compute/Windows
    if echo "$rg_list" | grep -qiE "lesson.?05|compute|windows"; then
        run_validation "05"
    fi

    # Lesson 06: Linux/Kubernetes
    if echo "$rg_list" | grep -qiE "lesson.?06|linux|k8s|microk8s"; then
        run_validation "06"
    fi

    # Lesson 07: Containers
    if echo "$rg_list" | grep -qiE "lesson.?07|container"; then
        run_validation "07"
    fi

    # Lesson 08: Serverless/Functions
    if echo "$rg_list" | grep -qiE "lesson.?08|serverless|function"; then
        run_validation "08"
    fi

    # Lesson 09: Database/Cosmos
    if echo "$rg_list" | grep -qiE "lesson.?09|database|cosmos"; then
        run_validation "09"
    fi

    # Lesson 11: AI
    if echo "$rg_list" | grep -qiE "lesson.?11|ai-foundry|ai.foundry"; then
        run_validation "11"
    fi
fi

# Summary
print_header "📊 Validation Summary"
echo ""
if [[ $TOTAL_FAILED -eq 0 && $TOTAL_PASSED -gt 0 ]]; then
    echo -e "  ${GREEN}${BOLD}All validations PASSED!${NC} (${TOTAL_PASSED} lessons)"
    echo ""
    echo -e "  ${CYAN}Your Azure Essentials environment is ready for training.${NC}"
elif [[ $TOTAL_PASSED -gt 0 ]]; then
    echo -e "  ${YELLOW}${BOLD}Partial success:${NC} ${TOTAL_PASSED} passed, ${TOTAL_FAILED} failed"
    echo ""
    echo -e "  ${YELLOW}Some lessons may need redeployment.${NC}"
else
    echo -e "  ${RED}${BOLD}No validations passed.${NC}"
    echo ""
    echo -e "  ${RED}Check that resources are deployed and accessible.${NC}"
fi

echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${DIM}Code to Cloud | www.codetocloud.io${NC}"
echo ""
