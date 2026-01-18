#!/bin/bash
#===============================================================================
# Azure Essentials Course - Pure Azure CLI Deployment Script
#===============================================================================
# This script deploys lesson resources using Azure CLI commands directly,
# without Bicep templates. This is an alternative to the azd-based deployments
# and helps learners understand the underlying Azure CLI commands.
#===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
LOCATION="${AZURE_LOCATION:-uksouth}"
ENV_NAME="${AZURE_ENV_NAME:-azureessentials}"
RESOURCE_GROUP_PREFIX="rg-${ENV_NAME}"

# Track what was deployed for cleanup
DEPLOYED_RESOURCES=()

#===============================================================================
# Utility Functions
#===============================================================================

print_banner() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${BOLD}${CYAN}☁️  Azure Essentials - Pure Azure CLI Deployment${NC}                            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Deploy lesson resources using native Azure CLI commands                     ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

generate_unique_suffix() {
    echo $(openssl rand -hex 4)
}

#===============================================================================
# Prerequisites Check
#===============================================================================

check_prerequisites() {
    print_section "🔍 Checking Prerequisites"

    local missing=0

    # Check Azure CLI
    if command -v az &> /dev/null; then
        local az_version=$(az version --query '"azure-cli"' -o tsv 2>/dev/null)
        print_success "Azure CLI installed (v${az_version})"
    else
        print_error "Azure CLI not installed"
        echo "       Install: https://docs.microsoft.com/cli/azure/install-azure-cli"
        missing=1
    fi

    # Check if logged in
    if az account show &> /dev/null; then
        local account=$(az account show --query name -o tsv)
        local sub_id=$(az account show --query id -o tsv)
        print_success "Logged in to Azure"
        print_info "Subscription: ${account}"
        print_info "ID: ${sub_id:0:8}...${sub_id: -4}"
    else
        print_error "Not logged in to Azure"
        echo "       Run: az login"
        missing=1
    fi

    if [[ $missing -eq 1 ]]; then
        echo ""
        print_error "Please install missing prerequisites and try again."
        exit 1
    fi

    echo ""
    print_success "All prerequisites satisfied!"
}

#===============================================================================
# Lesson Selection Menu
#===============================================================================

select_lesson() {
    print_section "📚 Select Lesson to Deploy"

    echo -e "Each lesson deploys to its ${CYAN}own resource group${NC} for easy cleanup."
    echo -e "Resources are created using ${GREEN}native Azure CLI commands${NC}."
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  DAY 1 - FOUNDATIONS                                                         ${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}1)${NC} Introduction to Azure      ${GREEN}[NO RESOURCES]${NC} Portal & CLI basics"
    echo -e "   ${CYAN}2)${NC} Getting Started            ${YELLOW}[TENANT]${NC}       Management Groups"
    echo -e "   ${CYAN}3)${NC} Storage Services           ${GREEN}[FREE]${NC}         Storage Account"
    echo -e "   ${CYAN}4)${NC} Networking Services        ${GREEN}[FREE]${NC}         VNet, Subnet, NSG"
    echo -e "   ${CYAN}5)${NC} Compute: Windows           ${YELLOW}[QUOTA: B2s]${NC}  Windows VM + App Service"
    echo -e "   ${CYAN}6)${NC} Compute: Linux & K8s       ${YELLOW}[QUOTA: B2s]${NC}  Ubuntu VM + MicroK8s"
    echo -e "   ${CYAN}7)${NC} Container Services         ${YELLOW}[~\$5/mo]${NC}       Container Registry"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  DAY 2 - ADVANCED SERVICES                                                   ${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}8)${NC} Serverless Services        ${YELLOW}[QUOTA]${NC}        Azure Functions"
    echo -e "   ${CYAN}9)${NC} Database Services          ${YELLOW}[Pay-per-use]${NC}  Cosmos DB Serverless"
    echo -e "  ${CYAN}10)${NC} Billing & Cost             ${GREEN}[NO RESOURCES]${NC} Portal demo only"
    echo -e "  ${CYAN}11)${NC} AI Foundry                 ${YELLOW}[Pay-per-use]${NC}  AI Hub + Project"
    echo -e "  ${CYAN}12)${NC} Architecture & Design      ${GREEN}[NO RESOURCES]${NC} Best practices"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}0)${NC} Deploy ALL lessons         ${RED}[FULL COURSE]${NC}  Complete deployment"
    echo -e "   ${CYAN}c)${NC} Cleanup resources          ${RED}[DELETE]${NC}       Remove lesson resources"
    echo -e "   ${CYAN}q)${NC} Quit"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "Select an option [1-12, 0, c, q]: " choice

    SELECTED_LESSON="$choice"
}

#===============================================================================
# Resource Group Management
#===============================================================================

create_resource_group() {
    local lesson_num=$1
    local rg_name="${RESOURCE_GROUP_PREFIX}-lesson${lesson_num}"

    print_info "Creating resource group: ${rg_name}"

    az group create \
        --name "$rg_name" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=$lesson_num" "deployed-by=azure-cli" \
        --output none

    print_success "Resource group created: ${rg_name}"
    DEPLOYED_RESOURCES+=("$rg_name")

    echo "$rg_name"
}

#===============================================================================
# Lesson 2: Management Groups
#===============================================================================

deploy_lesson_2() {
    print_section "📦 Lesson 2: Management Groups"

    print_warning "Management Groups require Tenant-level permissions."
    print_info "This creates a demo management group structure."
    echo ""
    read -p "Do you have tenant admin permissions? (y/n): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_warning "Skipping Management Groups deployment."
        return
    fi

    local mg_prefix="mg-${ENV_NAME}"
    local tenant_id=$(az account show --query tenantId -o tsv)

    print_info "Creating management group: ${mg_prefix}-root"
    az account management-group create \
        --name "${mg_prefix}-root" \
        --display-name "Azure Essentials Root" \
        --output none 2>/dev/null || print_warning "Management group may already exist"

    print_info "Creating child management groups..."

    for child in "production" "development" "sandbox"; do
        az account management-group create \
            --name "${mg_prefix}-${child}" \
            --display-name "Azure Essentials ${child^}" \
            --parent "${mg_prefix}-root" \
            --output none 2>/dev/null || true
    done

    print_success "Management Groups created!"
    echo ""
    print_info "View in portal: https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups"
}

#===============================================================================
# Lesson 3: Storage Services
#===============================================================================

deploy_lesson_3() {
    print_section "📦 Lesson 3: Storage Services"

    local rg_name=$(create_resource_group 3)
    local suffix=$(generate_unique_suffix)
    local storage_name="st${ENV_NAME}${suffix}"

    # Ensure storage name is valid (3-24 chars, lowercase alphanumeric)
    storage_name=$(echo "$storage_name" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9' | cut -c1-24)

    print_info "Creating storage account: ${storage_name}"

    az storage account create \
        --name "$storage_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --access-tier Hot \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access false \
        --tags "course=azure-essentials" "lesson=3" \
        --output none

    print_success "Storage account created: ${storage_name}"

    # Create containers
    print_info "Creating blob containers..."
    local account_key=$(az storage account keys list --account-name "$storage_name" --resource-group "$rg_name" --query '[0].value' -o tsv)

    for container in "documents" "images" "backups"; do
        az storage container create \
            --name "$container" \
            --account-name "$storage_name" \
            --account-key "$account_key" \
            --output none
        print_success "Container created: ${container}"
    done

    # Create a queue
    print_info "Creating queue..."
    az storage queue create \
        --name "messages" \
        --account-name "$storage_name" \
        --account-key "$account_key" \
        --output none
    print_success "Queue created: messages"

    # Create a table
    print_info "Creating table..."
    az storage table create \
        --name "logs" \
        --account-name "$storage_name" \
        --account-key "$account_key" \
        --output none
    print_success "Table created: logs"

    echo ""
    print_success "Lesson 3 deployment complete!"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    echo "  Storage Account: ${storage_name}"
    echo "  Resource Group:  ${rg_name}"
    echo "  Containers:      documents, images, backups"
    echo "  Queue:           messages"
    echo "  Table:           logs"
}

#===============================================================================
# Lesson 4: Networking Services
#===============================================================================

deploy_lesson_4() {
    print_section "📦 Lesson 4: Networking Services"

    local rg_name=$(create_resource_group 4)
    local vnet_name="vnet-${ENV_NAME}"

    print_info "Creating virtual network: ${vnet_name}"

    az network vnet create \
        --name "$vnet_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --address-prefix "10.0.0.0/16" \
        --tags "course=azure-essentials" "lesson=4" \
        --output none

    print_success "Virtual network created: ${vnet_name}"

    # Create subnets
    print_info "Creating subnets..."

    az network vnet subnet create \
        --name "snet-web" \
        --vnet-name "$vnet_name" \
        --resource-group "$rg_name" \
        --address-prefixes "10.0.1.0/24" \
        --output none
    print_success "Subnet created: snet-web (10.0.1.0/24)"

    az network vnet subnet create \
        --name "snet-app" \
        --vnet-name "$vnet_name" \
        --resource-group "$rg_name" \
        --address-prefixes "10.0.2.0/24" \
        --output none
    print_success "Subnet created: snet-app (10.0.2.0/24)"

    az network vnet subnet create \
        --name "snet-data" \
        --vnet-name "$vnet_name" \
        --resource-group "$rg_name" \
        --address-prefixes "10.0.3.0/24" \
        --output none
    print_success "Subnet created: snet-data (10.0.3.0/24)"

    # Create NSG
    local nsg_name="nsg-${ENV_NAME}-web"
    print_info "Creating network security group: ${nsg_name}"

    az network nsg create \
        --name "$nsg_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --tags "course=azure-essentials" "lesson=4" \
        --output none

    # Add NSG rules
    az network nsg rule create \
        --name "AllowHTTP" \
        --nsg-name "$nsg_name" \
        --resource-group "$rg_name" \
        --priority 100 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --destination-port-ranges 80 \
        --output none

    az network nsg rule create \
        --name "AllowHTTPS" \
        --nsg-name "$nsg_name" \
        --resource-group "$rg_name" \
        --priority 110 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --destination-port-ranges 443 \
        --output none

    print_success "NSG created with HTTP/HTTPS rules"

    # Associate NSG with web subnet
    az network vnet subnet update \
        --name "snet-web" \
        --vnet-name "$vnet_name" \
        --resource-group "$rg_name" \
        --network-security-group "$nsg_name" \
        --output none

    print_success "NSG associated with snet-web subnet"

    echo ""
    print_success "Lesson 4 deployment complete!"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    echo "  Virtual Network: ${vnet_name}"
    echo "  Address Space:   10.0.0.0/16"
    echo "  Subnets:         snet-web, snet-app, snet-data"
    echo "  NSG:             ${nsg_name}"
    echo "  Resource Group:  ${rg_name}"
}

#===============================================================================
# Lesson 5: Compute Windows
#===============================================================================

deploy_lesson_5() {
    print_section "📦 Lesson 5: Compute - Windows"

    # Get password
    echo ""
    print_info "Windows VM requires an admin password."
    echo "Password requirements:"
    echo "  - At least 12 characters"
    echo "  - Contains uppercase, lowercase, and number"
    echo ""

    while true; do
        read -sp "Enter Windows admin password: " WIN_PASSWORD
        echo ""

        if [[ ${#WIN_PASSWORD} -lt 12 ]]; then
            print_error "Password must be at least 12 characters"
            continue
        fi
        if [[ ! "$WIN_PASSWORD" =~ [A-Z] ]]; then
            print_error "Password must contain uppercase letter"
            continue
        fi
        if [[ ! "$WIN_PASSWORD" =~ [a-z] ]]; then
            print_error "Password must contain lowercase letter"
            continue
        fi
        if [[ ! "$WIN_PASSWORD" =~ [0-9] ]]; then
            print_error "Password must contain a number"
            continue
        fi
        break
    done

    local rg_name=$(create_resource_group 5)
    local suffix=$(generate_unique_suffix)
    local vm_name="vm-win-${suffix}"
    local vnet_name="vnet-${vm_name}"
    local pip_name="pip-${vm_name}"
    local nsg_name="nsg-${vm_name}"
    local nic_name="nic-${vm_name}"

    # Create VNet
    print_info "Creating virtual network..."
    az network vnet create \
        --name "$vnet_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --address-prefix "10.1.0.0/16" \
        --subnet-name "default" \
        --subnet-prefix "10.1.0.0/24" \
        --output none
    print_success "VNet created: ${vnet_name}"

    # Create Public IP
    print_info "Creating public IP..."
    az network public-ip create \
        --name "$pip_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --allocation-method Static \
        --sku Standard \
        --dns-name "${vm_name}-${suffix}" \
        --output none
    print_success "Public IP created: ${pip_name}"

    # Create NSG with RDP rule
    print_info "Creating NSG with RDP rule..."
    az network nsg create \
        --name "$nsg_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --output none

    az network nsg rule create \
        --name "AllowRDP" \
        --nsg-name "$nsg_name" \
        --resource-group "$rg_name" \
        --priority 1000 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --destination-port-ranges 3389 \
        --output none
    print_success "NSG created with RDP rule"

    # Create NIC
    print_info "Creating network interface..."
    az network nic create \
        --name "$nic_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --vnet-name "$vnet_name" \
        --subnet "default" \
        --public-ip-address "$pip_name" \
        --network-security-group "$nsg_name" \
        --output none
    print_success "NIC created: ${nic_name}"

    # Create Windows VM
    print_info "Creating Windows Server 2022 VM (this takes 2-3 minutes)..."
    az vm create \
        --name "$vm_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --nics "$nic_name" \
        --image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest" \
        --size "Standard_B2s" \
        --admin-username "azureuser" \
        --admin-password "$WIN_PASSWORD" \
        --os-disk-name "${vm_name}-osdisk" \
        --storage-sku StandardSSD_LRS \
        --output none
    print_success "Windows VM created: ${vm_name}"

    # Configure auto-shutdown
    print_info "Configuring auto-shutdown at 7 PM UTC..."
    local sub_id=$(az account show --query id -o tsv)
    az resource create \
        --resource-group "$rg_name" \
        --resource-type "Microsoft.DevTestLab/schedules" \
        --name "shutdown-computevm-${vm_name}" \
        --properties "{
            \"status\": \"Enabled\",
            \"taskType\": \"ComputeVmShutdownTask\",
            \"dailyRecurrence\": { \"time\": \"1900\" },
            \"timeZoneId\": \"UTC\",
            \"notificationSettings\": { \"status\": \"Disabled\" },
            \"targetResourceId\": \"/subscriptions/${sub_id}/resourceGroups/${rg_name}/providers/Microsoft.Compute/virtualMachines/${vm_name}\"
        }" \
        --output none 2>/dev/null || print_warning "Auto-shutdown may need manual setup"
    print_success "Auto-shutdown configured"

    # Create App Service
    local app_name="app-${ENV_NAME}-${suffix}"
    local plan_name="asp-${ENV_NAME}-${suffix}"

    print_info "Creating App Service Plan (Free tier)..."
    az appservice plan create \
        --name "$plan_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --sku F1 \
        --output none
    print_success "App Service Plan created: ${plan_name}"

    print_info "Creating Web App..."
    az webapp create \
        --name "$app_name" \
        --resource-group "$rg_name" \
        --plan "$plan_name" \
        --runtime "DOTNET|8.0" \
        --output none 2>/dev/null || az webapp create \
        --name "$app_name" \
        --resource-group "$rg_name" \
        --plan "$plan_name" \
        --output none
    print_success "Web App created: ${app_name}"

    # Get outputs
    local public_ip=$(az network public-ip show --name "$pip_name" --resource-group "$rg_name" --query ipAddress -o tsv)
    local fqdn=$(az network public-ip show --name "$pip_name" --resource-group "$rg_name" --query dnsSettings.fqdn -o tsv)

    echo ""
    print_success "Lesson 5 deployment complete!"
    echo ""
    echo -e "${CYAN}Windows VM:${NC}"
    echo "  Name:        ${vm_name}"
    echo "  Public IP:   ${public_ip}"
    echo "  FQDN:        ${fqdn}"
    echo "  Username:    azureuser"
    echo "  RDP Command: mstsc /v:${fqdn}"
    echo ""
    echo -e "${CYAN}App Service:${NC}"
    echo "  Name: ${app_name}"
    echo "  URL:  https://${app_name}.azurewebsites.net"
    echo ""
    echo "  Resource Group: ${rg_name}"
}

#===============================================================================
# Lesson 6: Compute Linux
#===============================================================================

deploy_lesson_6() {
    print_section "📦 Lesson 6: Compute - Linux & Kubernetes"

    local rg_name=$(create_resource_group 6)
    local suffix=$(generate_unique_suffix)
    local vm_name="vm-linux-${suffix}"

    print_info "Creating Ubuntu VM with MicroK8s (this takes 2-3 minutes)..."

    # Cloud-init to install MicroK8s
    local cloud_init=$(cat <<'EOF'
#cloud-config
package_update: true
package_upgrade: true
packages:
  - snapd
runcmd:
  - snap install microk8s --classic
  - usermod -a -G microk8s azureuser
  - mkdir -p /home/azureuser/.kube
  - chown -R azureuser:azureuser /home/azureuser/.kube
  - microk8s status --wait-ready
  - microk8s enable dns dashboard storage
EOF
)

    echo "$cloud_init" > /tmp/cloud-init.yaml

    az vm create \
        --name "$vm_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --image "Canonical:ubuntu-24_04-lts:server:latest" \
        --size "Standard_B2s" \
        --admin-username "azureuser" \
        --generate-ssh-keys \
        --public-ip-sku Standard \
        --custom-data /tmp/cloud-init.yaml \
        --output none

    rm -f /tmp/cloud-init.yaml
    print_success "Ubuntu VM created with MicroK8s: ${vm_name}"

    # Open ports
    print_info "Opening SSH and kubectl ports..."
    az vm open-port \
        --name "$vm_name" \
        --resource-group "$rg_name" \
        --port 22 \
        --priority 1000 \
        --output none

    az vm open-port \
        --name "$vm_name" \
        --resource-group "$rg_name" \
        --port 16443 \
        --priority 1010 \
        --output none
    print_success "Ports opened: 22 (SSH), 16443 (kubectl)"

    # Get outputs
    local public_ip=$(az vm show --name "$vm_name" --resource-group "$rg_name" --show-details --query publicIps -o tsv)

    echo ""
    print_success "Lesson 6 deployment complete!"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    echo "  VM Name:     ${vm_name}"
    echo "  Public IP:   ${public_ip}"
    echo "  Username:    azureuser"
    echo "  SSH Command: ssh azureuser@${public_ip}"
    echo ""
    echo "  MicroK8s will be ready in ~5 minutes after VM boot."
    echo "  SSH in and run: microk8s status"
    echo ""
    echo "  Resource Group: ${rg_name}"
}

#===============================================================================
# Lesson 7: Container Registry
#===============================================================================

deploy_lesson_7() {
    print_section "📦 Lesson 7: Container Services"

    local rg_name=$(create_resource_group 7)
    local suffix=$(generate_unique_suffix)
    local acr_name="acr${ENV_NAME}${suffix}"

    # Ensure ACR name is valid
    acr_name=$(echo "$acr_name" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9' | cut -c1-50)

    print_info "Creating Azure Container Registry: ${acr_name}"

    az acr create \
        --name "$acr_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --sku Basic \
        --admin-enabled true \
        --tags "course=azure-essentials" "lesson=7" \
        --output none

    print_success "Container Registry created: ${acr_name}"

    # Get login credentials
    local login_server=$(az acr show --name "$acr_name" --resource-group "$rg_name" --query loginServer -o tsv)
    local admin_user=$(az acr credential show --name "$acr_name" --resource-group "$rg_name" --query username -o tsv)
    local admin_pass=$(az acr credential show --name "$acr_name" --resource-group "$rg_name" --query "passwords[0].value" -o tsv)

    echo ""
    print_success "Lesson 7 deployment complete!"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    echo "  Registry Name:  ${acr_name}"
    echo "  Login Server:   ${login_server}"
    echo "  Admin User:     ${admin_user}"
    echo "  Admin Password: ${admin_pass:0:8}..."
    echo ""
    echo "  Docker Login:   docker login ${login_server} -u ${admin_user}"
    echo ""
    echo "  Resource Group: ${rg_name}"
}

#===============================================================================
# Lesson 8: Serverless (Functions)
#===============================================================================

deploy_lesson_8() {
    print_section "📦 Lesson 8: Serverless Services"

    local rg_name=$(create_resource_group 8)
    local suffix=$(generate_unique_suffix)
    local storage_name="stfunc${suffix}"
    local func_name="func-${ENV_NAME}-${suffix}"

    # Create storage account for function
    print_info "Creating storage account for Functions..."
    az storage account create \
        --name "$storage_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --output none
    print_success "Storage account created: ${storage_name}"

    # Create function app
    print_info "Creating Function App..."
    az functionapp create \
        --name "$func_name" \
        --resource-group "$rg_name" \
        --storage-account "$storage_name" \
        --consumption-plan-location "$LOCATION" \
        --runtime python \
        --runtime-version 3.11 \
        --functions-version 4 \
        --os-type Linux \
        --output none
    print_success "Function App created: ${func_name}"

    echo ""
    print_success "Lesson 8 deployment complete!"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    echo "  Function App:    ${func_name}"
    echo "  URL:             https://${func_name}.azurewebsites.net"
    echo "  Storage Account: ${storage_name}"
    echo ""
    echo "  Resource Group:  ${rg_name}"
}

#===============================================================================
# Lesson 9: Cosmos DB
#===============================================================================

deploy_lesson_9() {
    print_section "📦 Lesson 9: Database Services"

    local rg_name=$(create_resource_group 9)
    local suffix=$(generate_unique_suffix)
    local cosmos_name="cosmos-${ENV_NAME}-${suffix}"

    print_info "Creating Cosmos DB account (this takes 3-5 minutes)..."

    az cosmosdb create \
        --name "$cosmos_name" \
        --resource-group "$rg_name" \
        --locations regionName="$LOCATION" failoverPriority=0 isZoneRedundant=false \
        --default-consistency-level Session \
        --enable-serverless true \
        --tags "course=azure-essentials" "lesson=9" \
        --output none
    print_success "Cosmos DB account created: ${cosmos_name}"

    # Create database and container
    print_info "Creating database and container..."
    az cosmosdb sql database create \
        --account-name "$cosmos_name" \
        --resource-group "$rg_name" \
        --name "coursedb" \
        --output none

    az cosmosdb sql container create \
        --account-name "$cosmos_name" \
        --resource-group "$rg_name" \
        --database-name "coursedb" \
        --name "items" \
        --partition-key-path "/category" \
        --output none
    print_success "Database 'coursedb' and container 'items' created"

    # Get endpoint
    local endpoint=$(az cosmosdb show --name "$cosmos_name" --resource-group "$rg_name" --query documentEndpoint -o tsv)

    echo ""
    print_success "Lesson 9 deployment complete!"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    echo "  Account Name: ${cosmos_name}"
    echo "  Endpoint:     ${endpoint}"
    echo "  Database:     coursedb"
    echo "  Container:    items"
    echo ""
    echo "  Resource Group: ${rg_name}"
}

#===============================================================================
# Lesson 11: AI Foundry
#===============================================================================

deploy_lesson_11() {
    print_section "📦 Lesson 11: AI Foundry"

    local rg_name=$(create_resource_group 11)
    local suffix=$(generate_unique_suffix)
    local ai_name="ai-${ENV_NAME}-${suffix}"

    print_warning "AI Foundry resources require specific region availability."
    print_info "Creating Azure AI Services account..."

    az cognitiveservices account create \
        --name "$ai_name" \
        --resource-group "$rg_name" \
        --location "$LOCATION" \
        --kind "OpenAI" \
        --sku S0 \
        --custom-domain "$ai_name" \
        --output none 2>/dev/null || {
            print_warning "OpenAI may not be available in ${LOCATION}, trying CognitiveServices..."
            az cognitiveservices account create \
                --name "$ai_name" \
                --resource-group "$rg_name" \
                --location "$LOCATION" \
                --kind "CognitiveServices" \
                --sku S0 \
                --output none
        }
    print_success "AI Services account created: ${ai_name}"

    # Get endpoint
    local endpoint=$(az cognitiveservices account show --name "$ai_name" --resource-group "$rg_name" --query properties.endpoint -o tsv 2>/dev/null || echo "N/A")

    echo ""
    print_success "Lesson 11 deployment complete!"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    echo "  AI Account: ${ai_name}"
    echo "  Endpoint:   ${endpoint}"
    echo ""
    echo "  Resource Group: ${rg_name}"
}

#===============================================================================
# Cleanup Function
#===============================================================================

cleanup_resources() {
    print_section "🧹 Cleanup Resources"

    echo "This will delete resource groups for lessons 3-11."
    echo ""

    # List existing resource groups
    local rgs=$(az group list --query "[?contains(name, '${RESOURCE_GROUP_PREFIX}')].name" -o tsv)

    if [[ -z "$rgs" ]]; then
        print_info "No Azure Essentials resource groups found."
        return
    fi

    echo "Found resource groups:"
    echo "$rgs" | while read rg; do
        echo "  - $rg"
    done
    echo ""

    read -p "Delete all these resource groups? (y/n): " confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo "$rgs" | while read rg; do
            print_info "Deleting: $rg"
            az group delete --name "$rg" --yes --no-wait
        done
        print_success "Deletion initiated. Resources will be removed in background."
    else
        print_info "Cleanup cancelled."
    fi

    # Ask about management groups
    echo ""
    read -p "Also delete management groups? (y/n): " mg_confirm
    if [[ "$mg_confirm" == "y" || "$mg_confirm" == "Y" ]]; then
        local mg_prefix="mg-${ENV_NAME}"
        for mg in "sandbox" "development" "production" "root"; do
            az account management-group delete --name "${mg_prefix}-${mg}" 2>/dev/null || true
        done
        print_success "Management groups deleted."
    fi
}

#===============================================================================
# Deploy All Lessons
#===============================================================================

deploy_all() {
    print_section "🚀 Deploying ALL Lessons"

    echo "This will deploy resources for lessons 2-11."
    echo ""
    read -p "Continue? (y/n): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        return
    fi

    deploy_lesson_2
    deploy_lesson_3
    deploy_lesson_4
    deploy_lesson_5
    deploy_lesson_6
    deploy_lesson_7
    deploy_lesson_8
    deploy_lesson_9
    deploy_lesson_11

    print_section "✅ All Lessons Deployed!"
}

#===============================================================================
# Dispatch Function
#===============================================================================

deploy_lesson() {
    case $SELECTED_LESSON in
        1)
            print_info "Lesson 1 is a portal/CLI demo - no resources to deploy."
            ;;
        2)
            deploy_lesson_2
            ;;
        3)
            deploy_lesson_3
            ;;
        4)
            deploy_lesson_4
            ;;
        5)
            deploy_lesson_5
            ;;
        6)
            deploy_lesson_6
            ;;
        7)
            deploy_lesson_7
            ;;
        8)
            deploy_lesson_8
            ;;
        9)
            deploy_lesson_9
            ;;
        10)
            print_info "Lesson 10 is a portal demo - no resources to deploy."
            ;;
        11)
            deploy_lesson_11
            ;;
        12)
            print_info "Lesson 12 is architecture design - no resources to deploy."
            ;;
        0)
            deploy_all
            ;;
        c|C)
            cleanup_resources
            ;;
        q|Q)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option: $SELECTED_LESSON"
            ;;
    esac
}

#===============================================================================
# Main
#===============================================================================

main() {
    print_banner
    check_prerequisites

    while true; do
        select_lesson
        deploy_lesson

        echo ""
        read -p "Deploy another lesson? (y/n): " continue_choice
        if [[ "$continue_choice" != "y" && "$continue_choice" != "Y" ]]; then
            break
        fi
    done

    print_section "👋 Thank you for using Azure Essentials!"
    echo ""
    echo "Don't forget to clean up resources when done to avoid charges."
    echo "Run this script again and select 'c' for cleanup."
    echo ""
}

main "$@"
