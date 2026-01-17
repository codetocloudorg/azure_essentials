#!/bin/bash
# Azure Essentials - Interactive Deployment Menu
# Code to Cloud
# This script provides a guided deployment experience for learners

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

# Print banner with ASCII logo
print_banner() {
    clear
    echo ""
    echo -e "${CYAN}██████  ██████  ██████  ███████     ████████  ██████       ██████ ██       ██████  ██    ██ ██████${NC}"
    echo -e "${CYAN}██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██${NC}"
    echo -e "${CYAN}██      ██    ██ ██   ██ █████          ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██${NC}"
    echo -e "${CYAN}██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██${NC}"
    echo -e "${CYAN} ██████  ██████  ██████  ███████        ██     ██████       ██████ ███████  ██████   ██████  ██████${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${MAGENTA}\"There is no spoon. Only the code.\"${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "   ${BOLD}Azure Essentials${NC} - Interactive Deployment"
    echo -e "   ${BLUE}www.codetocloud.io${NC}"
    echo ""
}

# Print section header
print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    print_section "📋 Checking Prerequisites"

    local missing=0

    # Check Azure CLI
    if command -v az &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Azure CLI: $(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo 'installed')"
    else
        echo -e "  ${RED}✗${NC} Azure CLI: Not installed"
        echo -e "    Install: ${CYAN}https://aka.ms/installazurecli${NC}"
        missing=1
    fi

    # Check Azure Developer CLI
    if command -v azd &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Azure Developer CLI: $(azd version 2>/dev/null | head -1)"
    else
        echo -e "  ${RED}✗${NC} Azure Developer CLI: Not installed"
        echo -e "    Install: ${CYAN}curl -fsSL https://aka.ms/install-azd.sh | bash${NC}"
        missing=1
    fi

    # Check authentication
    if az account show &> /dev/null; then
        local account=$(az account show --query name -o tsv 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} Azure Login: Signed in to '$account'"
    else
        echo -e "  ${YELLOW}○${NC} Azure Login: Not authenticated"
        needs_login=1
    fi

    if [ $missing -eq 1 ]; then
        echo ""
        echo -e "${RED}Please install missing prerequisites and try again.${NC}"
        exit 1
    fi

    echo ""
    echo -e "${GREEN}All prerequisites satisfied!${NC}"

    # Handle Azure login if needed
    if [ "${needs_login:-0}" -eq 1 ]; then
        echo ""
        print_section "🔐 Azure Login Required"
        echo "You need to sign in to Azure to continue."
        echo ""
        read -p "Press Enter to open the Azure login page in your browser..."
        echo ""
        echo -e "${CYAN}Opening browser for Azure login...${NC}"
        echo ""

        # Login to Azure CLI
        if ! az login; then
            echo -e "${RED}Azure CLI login failed. Please try again.${NC}"
            exit 1
        fi

        echo ""
        echo -e "${GREEN}✓ Azure CLI login successful!${NC}"
        echo ""

        # Login to Azure Developer CLI
        echo -e "${CYAN}Now authenticating Azure Developer CLI...${NC}"
        if ! azd auth login; then
            echo -e "${RED}Azure Developer CLI login failed. Please try again.${NC}"
            exit 1
        fi

        echo ""
        echo -e "${GREEN}✓ Azure Developer CLI login successful!${NC}"

        # Show current subscription
        local account=$(az account show --query name -o tsv 2>/dev/null)
        echo ""
        echo -e "Signed in to: ${BOLD}$account${NC}"
    fi
}

# Select region
select_region() {
    print_section "🌍 Select Azure Region"

    echo -e "These regions have the ${GREEN}best capacity${NC} for Azure free accounts:"
    echo ""
    echo -e "  ${BOLD}North America (Recommended):${NC}"
    echo -e "    1) ${CYAN}East US${NC}          - Virginia (Largest Azure region)"
    echo -e "    2) ${CYAN}East US 2${NC}        - Virginia (High availability)"
    echo -e "    3) ${CYAN}West US 2${NC}        - Washington"
    echo -e "    4) ${CYAN}Central US${NC}       - Iowa ${GREEN}(Best for Cosmos DB)${NC}"
    echo -e "    5) ${CYAN}Canada Central${NC}   - Toronto"
    echo ""

    while true; do
        read -p "Select region [1-5]: " region_choice
        case $region_choice in
            1) SELECTED_REGION="eastus"; break;;
            2) SELECTED_REGION="eastus2"; break;;
            3) SELECTED_REGION="westus2"; break;;
            4) SELECTED_REGION="centralus"; break;;
            5) SELECTED_REGION="canadacentral"; break;;
            *) echo -e "${RED}Invalid choice. Please enter 1-5.${NC}";;
        esac
    done

    echo ""
    echo -e "${GREEN}Selected region: ${BOLD}$SELECTED_REGION${NC}"
}

# Select lesson
select_lesson() {
    print_section "📚 Select Lesson to Deploy"

    echo -e "Each lesson deploys to its ${CYAN}own resource group${NC} for clarity."
    echo -e "Lessons 1, 10, 12 are ${GREEN}portal/CLI demos${NC} - no Azure resources needed."
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  DAY 1 - FOUNDATIONS                                                         ${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}1)${NC} Introduction to Azure      ${GREEN}[NO RESOURCES]${NC} Portal & CLI basics"
    echo -e "   ${CYAN}2)${NC} Getting Started            ${GREEN}[FREE]${NC}         Landing Zone RG demo"
    echo -e "   ${CYAN}3)${NC} Storage Services           ${GREEN}[FREE]${NC}         Blobs, queues, tables"
    echo -e "   ${CYAN}4)${NC} Networking Services        ${GREEN}[FREE]${NC}         VNets, subnets, NSGs"
    echo -e "   ${CYAN}5)${NC} Compute: Windows           ${YELLOW}[QUOTA: B1]${NC}    App Service Web App"
    echo -e "   ${CYAN}6)${NC} Compute: Linux & K8s       ${YELLOW}[QUOTA: B2s]${NC}   Ubuntu VM + MicroK8s"
    echo -e "   ${CYAN}7)${NC} Container Services         ${YELLOW}[~\$5/mo]${NC}       Azure Container Registry"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  DAY 2 - ADVANCED SERVICES                                                   ${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}8)${NC} Serverless Services        ${YELLOW}[QUOTA: Dynamic]${NC} Azure Functions, Logic Apps"
    echo -e "   ${CYAN}9)${NC} Database & Data Services   ${YELLOW}[Pay-per-use]${NC}  Cosmos DB Serverless"
    echo -e "  ${CYAN}10)${NC} Billing & Cost Mgmt        ${GREEN}[NO RESOURCES]${NC} Cost management demo"
    echo -e "  ${CYAN}11)${NC} Azure AI Foundry           ${RED}[\$1-5/day]${NC}     AI Hub, model catalog"
    echo -e "  ${CYAN}12)${NC} Architecture Design        ${GREEN}[NO RESOURCES]${NC} Whiteboard session"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}0)${NC} Deploy ALL Resources       ${RED}[ALL QUOTAS]${NC}   Lessons 2-9,11"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${MAGENTA}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAGENTA}│${NC} ${BOLD}💡 RESOURCE AVAILABILITY INFO:${NC}                                            ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}│${NC}                                                                           ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}│${NC}  ${GREEN}FREE${NC} = Works with Azure Free Account, no quota needed                    ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}│${NC}  ${YELLOW}QUOTA${NC} = Requires compute quota (some subscriptions have 0 quota)         ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}│${NC}  ${RED}\$\$\$${NC} = Incurs costs, not covered by free tier                             ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}│${NC}                                                                           ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}│${NC}  If deployment fails with 'quota' error, try: ${CYAN}3, 4, 7, or 9${NC}              ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}│${NC}  Request quota increase: ${CYAN}https://aka.ms/azurequotarequest${NC}                ${MAGENTA}│${NC}"
    echo -e "${MAGENTA}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""

    while true; do
        read -p "Select lesson [0-12]: " lesson_choice
        case $lesson_choice in
            0) SELECTED_LESSON=""; SSH_REQUIRED=1; break;;
            1) SELECTED_LESSON="01"; NO_RESOURCES=1; break;;
            2) SELECTED_LESSON="02"; break;;
            3) SELECTED_LESSON="03"; break;;
            4) SELECTED_LESSON="04"; break;;
            5) SELECTED_LESSON="05"; break;;
            6) SELECTED_LESSON="06"; SSH_REQUIRED=1; break;;
            7) SELECTED_LESSON="07"; break;;
            8) SELECTED_LESSON="08"; break;;
            9) SELECTED_LESSON="09"; break;;
            10) SELECTED_LESSON="10"; NO_RESOURCES=1; break;;
            11) SELECTED_LESSON="11"; break;;
            12) SELECTED_LESSON="12"; NO_RESOURCES=1; break;;
            *) echo -e "${RED}Invalid choice. Please enter 0-12.${NC}";;
        esac
    done

    # Handle lessons that don't need Azure resources
    if [ "${NO_RESOURCES:-0}" -eq 1 ]; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  ✅ Lesson $SELECTED_LESSON is a demo/discussion - no deployment needed!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "Navigate to the lesson folder to follow along:"
        echo -e "  ${CYAN}cd lessons/${SELECTED_LESSON}-*/README.md${NC}"
        echo ""
        echo -e "Or view the lesson README directly in VS Code."
        echo ""
        read -p "Press Enter to exit..."
        exit 0
    fi

    if [ -z "$SELECTED_LESSON" ]; then
        echo -e "${YELLOW}⚠️  Deploying ALL lessons will create multiple resource groups and may incur costs.${NC}"
        read -p "Are you sure? (y/n): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            select_lesson
            return
        fi
    fi

    echo ""
    if [ -z "$SELECTED_LESSON" ]; then
        echo -e "${GREEN}Selected: ${BOLD}All Lessons${NC}"
    else
        echo -e "${GREEN}Selected: ${BOLD}Lesson $SELECTED_LESSON${NC}"
    fi
}

# Get environment name
get_environment_name() {
    print_section "🏷️  Environment Name"

    echo "Enter a unique name for your environment."
    echo "This will be used in resource group names (e.g., rg-{name}-lesson03-storage)"
    echo ""

    local default_name="azlearn-$(whoami | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c1-8)"
    read -p "Environment name [$default_name]: " env_name

    if [ -z "$env_name" ]; then
        ENV_NAME="$default_name"
    else
        ENV_NAME=$(echo "$env_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
    fi

    echo ""
    echo -e "${GREEN}Environment name: ${BOLD}$ENV_NAME${NC}"
}

# Handle SSH key for VM deployments (Lesson 06)
setup_ssh_key() {
    if [ "${SSH_REQUIRED:-0}" -ne 1 ]; then
        return
    fi

    print_section "🔑 SSH Key Setup"

    echo "Lesson 6 deploys an Ubuntu VM that requires SSH key authentication."
    echo ""

    # Check for existing SSH key
    if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        echo -e "${GREEN}✓ Found existing SSH key: ~/.ssh/id_rsa.pub${NC}"
        echo ""
        read -p "Use this key? (y/n) [y]: " use_existing
        if [ "$use_existing" != "n" ] && [ "$use_existing" != "N" ]; then
            SSH_PUBLIC_KEY=$(cat "$HOME/.ssh/id_rsa.pub")
            echo -e "${GREEN}Using existing SSH key.${NC}"
            return
        fi
    elif [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
        echo -e "${GREEN}✓ Found existing SSH key: ~/.ssh/id_ed25519.pub${NC}"
        echo ""
        read -p "Use this key? (y/n) [y]: " use_existing
        if [ "$use_existing" != "n" ] && [ "$use_existing" != "N" ]; then
            SSH_PUBLIC_KEY=$(cat "$HOME/.ssh/id_ed25519.pub")
            echo -e "${GREEN}Using existing SSH key.${NC}"
            return
        fi
    fi

    # No existing key or user declined - generate new one
    echo "No SSH key found or you chose not to use existing key."
    echo ""
    read -p "Generate a new SSH key pair? (y/n) [y]: " generate_key

    if [ "$generate_key" = "n" ] || [ "$generate_key" = "N" ]; then
        echo ""
        echo -e "${YELLOW}You'll need to provide an SSH public key for VM access.${NC}"
        echo "Enter your SSH public key (starts with ssh-rsa or ssh-ed25519):"
        read -p "> " SSH_PUBLIC_KEY

        if [ -z "$SSH_PUBLIC_KEY" ]; then
            echo -e "${RED}No SSH key provided. Cannot deploy Lesson 06.${NC}"
            exit 1
        fi
    else
        echo ""
        echo -e "${CYAN}Generating new SSH key pair...${NC}"
        ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519_azure" -N "" -C "azure-essentials-vm"
        SSH_PUBLIC_KEY=$(cat "$HOME/.ssh/id_ed25519_azure.pub")
        echo ""
        echo -e "${GREEN}✓ SSH key generated: ~/.ssh/id_ed25519_azure${NC}"
        echo -e "${GREEN}✓ Private key: ~/.ssh/id_ed25519_azure${NC}"
        echo ""
        echo -e "${YELLOW}💡 To SSH to your VM after deployment:${NC}"
        echo -e "   ${CYAN}ssh -i ~/.ssh/id_ed25519_azure azureuser@<vm-public-ip>${NC}"
    fi
    echo ""
}

# Confirm and deploy
confirm_and_deploy() {
    print_section "🚀 Ready to Deploy"

    echo -e "  Environment:  ${BOLD}$ENV_NAME${NC}"
    echo -e "  Region:       ${BOLD}$SELECTED_REGION${NC}"
    if [ -z "$SELECTED_LESSON" ]; then
        echo -e "  Lesson:       ${BOLD}All Lessons${NC}"
        echo ""
        echo -e "  ${CYAN}Resource groups to be created:${NC}"
        echo "    • rg-$ENV_NAME-lz-platform-* (6 Landing Zone RGs)"
        echo "    • rg-$ENV_NAME-lesson03-storage"
        echo "    • rg-$ENV_NAME-lesson04-networking"
        echo "    • rg-$ENV_NAME-lesson05-compute"
        echo "    • rg-$ENV_NAME-lesson06-linux-k8s"
        echo "    • rg-$ENV_NAME-lesson07-containers"
        echo "    • rg-$ENV_NAME-lesson08-serverless"
        echo "    • rg-$ENV_NAME-lesson09-database"
        echo "    • rg-$ENV_NAME-lesson11-ai-foundry"
    elif [ "$SELECTED_LESSON" = "02" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 02 - Landing Zone Demo${NC}"
        echo ""
        echo -e "  ${CYAN}Resource groups to be created (Landing Zone hierarchy):${NC}"
        echo "    • rg-$ENV_NAME-lz-platform-identity"
        echo "    • rg-$ENV_NAME-lz-platform-connectivity"
        echo "    • rg-$ENV_NAME-lz-platform-management"
        echo "    • rg-$ENV_NAME-lz-workloads-prod"
        echo "    • rg-$ENV_NAME-lz-workloads-nonprod"
        echo "    • rg-$ENV_NAME-lz-sandbox-learning"
    elif [ "$SELECTED_LESSON" = "06" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 06 - Linux & Kubernetes${NC}"
        echo ""
        echo -e "  ${CYAN}Resources to be created:${NC}"
        echo "    • rg-$ENV_NAME-lesson06-linux-k8s"
        echo "    • Ubuntu 22.04 LTS VM (Standard_B2s)"
        echo "    • MicroK8s pre-installed via cloud-init"
        echo "    • Public IP with SSH access"
    else
        echo -e "  Lesson:       ${BOLD}Lesson $SELECTED_LESSON${NC}"
        echo ""
        echo -e "  ${CYAN}Resource group to be created:${NC}"
        echo "    • rg-$ENV_NAME-lesson${SELECTED_LESSON}-*"
    fi
    echo ""

    read -p "Proceed with deployment? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}Deployment cancelled.${NC}"
        exit 0
    fi

    # Initialize azd environment
    print_section "⚙️  Initializing Environment"

    azd env new "$ENV_NAME" 2>/dev/null || azd env select "$ENV_NAME" 2>/dev/null || true
    azd env set AZURE_LOCATION "$SELECTED_REGION"

    if [ -n "$SELECTED_LESSON" ]; then
        azd env set LESSON_NUMBER "$SELECTED_LESSON"
    fi

    # Set SSH key if required
    if [ -n "$SSH_PUBLIC_KEY" ]; then
        azd env set SSH_PUBLIC_KEY "$SSH_PUBLIC_KEY"
    fi

    echo ""
    echo -e "${GREEN}Environment configured successfully!${NC}"

    # Run deployment
    print_section "☁️  Deploying to Azure"

    echo "This may take 5-15 minutes depending on the resources..."
    echo ""

    azd up
}

# Show completion message
show_completion() {
    echo ""
    echo ""
    echo -e "${GREEN}██████  ██████  ██████  ███████     ████████  ██████       ██████ ██       ██████  ██    ██ ██████${NC}"
    echo -e "${GREEN}██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██${NC}"
    echo -e "${GREEN}██      ██    ██ ██   ██ █████          ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██${NC}"
    echo -e "${GREEN}██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██${NC}"
    echo -e "${GREEN} ██████  ██████  ██████  ███████        ██     ██████       ██████ ███████  ██████   ██████  ██████${NC}"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${BOLD}✅ Deployment Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}Resource Groups Created:${NC}"
    az group list --query "[?contains(name, '$ENV_NAME')].{Name:name, Location:location}" -o table 2>/dev/null || echo "  Run 'az group list' to see your resource groups"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo "  1. Navigate to the lessons/ folder"
    echo "  2. Follow the README for your selected lesson"
    echo "  3. Explore resources in the Azure Portal"
    echo ""
    echo -e "${BOLD}Useful Commands:${NC}"
    echo -e "  ${CYAN}azd show${NC}          - View deployed resources"
    echo -e "  ${CYAN}azd down${NC}          - Delete all resources when done"
    echo -e "  ${CYAN}az group list${NC}     - List your resource groups"
    echo ""
    echo -e "${BLUE}Azure Portal:${NC} https://portal.azure.com"
    echo -e "${BLUE}Code to Cloud:${NC} www.codetocloud.io"
    echo ""
    echo -e "${YELLOW}⚠️  Remember to run 'azd down' when you're finished to avoid charges!${NC}"
    echo ""
}

# Main menu
main() {
    print_banner
    check_prerequisites
    get_environment_name
    select_region
    select_lesson
    setup_ssh_key
    confirm_and_deploy
    show_completion
}

# Run main function
main "$@"
