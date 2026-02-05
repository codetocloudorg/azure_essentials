#!/bin/bash
#===============================================================================
# Azure Essentials - Interactive Deployment Menu
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# PURPOSE:
#   Provides a guided, interactive deployment experience for the Azure
#   Essentials 2-Day training course. This script walks learners through:
#   - Prerequisites checking (Azure CLI, azd)
#   - Azure authentication
#   - Region selection (optimized for free tier availability)
#   - Lesson selection and deployment
#
# HOW DEPLOYMENT WORKS (THE TECHNOLOGY STACK):
#
#   ┌─────────────────────────────────────────────────────────────────────────┐
#   │  1. YOU RUN THIS SCRIPT (deploy.sh)                                     │
#   │     └─> Collects: environment name, region, lesson choice               │
#   │                                                                         │
#   │  2. AZURE DEVELOPER CLI (azd)                                           │
#   │     └─> Reads: azure.yaml (project definition)                          │
#   │     └─> Initializes: environment variables and parameters               │
#   │     └─> Orchestrates: the entire deployment process                     │
#   │                                                                         │
#   │  3. BICEP COMPILER                                                      │
#   │     └─> Input: /infra/main.bicep (Infrastructure as Code)               │
#   │     └─> Output: ARM JSON template (Azure Resource Manager format)       │
#   │     └─> Modules: /infra/modules/*.bicep (reusable components)           │
#   │                                                                         │
#   │  4. AZURE RESOURCE MANAGER (ARM)                                        │
#   │     └─> Receives: Compiled JSON template + parameters                   │
#   │     └─> Validates: Template syntax and resource availability            │
#   │     └─> Creates: Azure resources in your subscription                   │
#   │                                                                         │
#   │  5. AZURE RESOURCES                                                     │
#   │     └─> Resource groups, VMs, storage, networking, etc.                 │
#   │     └─> All tagged and organized by lesson                              │
#   └─────────────────────────────────────────────────────────────────────────┘
#
# KEY TECHNOLOGIES EXPLAINED:
#
#   BICEP:
#     - Azure's domain-specific language for Infrastructure as Code (IaC)
#     - Cleaner syntax than ARM JSON templates
#     - Files located in: /infra/main.bicep and /infra/modules/*.bicep
#     - Example: resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01'
#
#   AZURE DEVELOPER CLI (azd):
#     - High-level deployment orchestrator
#     - Commands: azd init, azd up, azd down
#     - Configuration: azure.yaml at project root
#     - Manages: infrastructure + application code together
#
#   ARM (Azure Resource Manager):
#     - Azure's deployment and management service
#     - All Azure operations go through ARM
#     - Provides: RBAC, tagging, resource organization
#
# DESIGNED FOR:
#   - macOS and Linux environments
#   - Windows users with Git Bash or WSL
#   - Azure Cloud Shell (bash mode)
#
# USAGE:
#   ./scripts/bash/deploy.sh
#
# REQUIREMENTS:
#   - Azure CLI (az) installed and logged in
#   - Azure Developer CLI (azd) installed
#   - Bash 4.0+ (default on macOS/Linux)
#
# THE DEPLOYMENT FLOW:
#   1. Check prerequisites → Login if needed
#   2. Choose environment name → Used for resource naming
#   3. Choose region → Where resources will be created
#   4. Choose lesson → Which infrastructure to deploy
#   5. Deploy via azd → Creates all Azure resources
#
# TRAINER NOTES:
#   - Use --verbose flag for detailed Azure CLI output during demos
#   - Each lesson deploys to its own resource group for isolation
#   - Cost estimates shown help learners understand pricing
#   - Free tier options (lessons 3, 4, 7, 9) work with $0 quota
#
#===============================================================================

# Exit immediately on error (fail-fast for training clarity)
set -e

#===============================================================================
# COLOR DEFINITIONS - For visual clarity during live training
#===============================================================================
# Using ANSI escape codes for cross-platform terminal compatibility.
# These make the output scannable and help learners follow along.
#
# HOW ANSI COLORS WORK:
#   - \033[ is the escape sequence that tells the terminal "color command coming"
#   - The number defines the color (31=red, 32=green, 33=yellow, etc.)
#   - 'm' ends the color code
#   - \033[0m resets to default (no color)
#
# Example: echo -e "${RED}Error!${NC}" prints "Error!" in red, then resets
#===============================================================================
RED='\033[0;31m'      # Errors, failures, warnings
GREEN='\033[0;32m'    # Success, completion, checkmarks
YELLOW='\033[1;33m'   # Cautions, important notes
BLUE='\033[0;34m'     # Links, informational
CYAN='\033[0;36m'     # Commands, technical details
MAGENTA='\033[0;35m'  # Highlights, special callouts
BOLD='\033[1m'        # Emphasis (works with colors too)
NC='\033[0m'          # No Color (reset to terminal default)

#===============================================================================
# PROMPT HELPER - Ensures prompts are visible in all terminal environments
#===============================================================================
# Some terminals (especially VS Code integrated terminal) may buffer output.
# This function ensures the prompt is visible before waiting for input.
prompt_user() {
    local prompt_text="$1"
    local var_name="$2"

    # Print prompt to stderr to ensure it's not buffered
    echo -ne "${CYAN}${prompt_text}${NC}" >&2

    # Read into the specified variable
    read "$var_name"
}

#===============================================================================
# BANNER FUNCTION - Creates visual separation for live training
#===============================================================================
# ASCII art banner helps attendees know they're in the right place
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

#===============================================================================
# SECTION HEADER FUNCTION - Visual separators for training flow
#===============================================================================
print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

#===============================================================================
# PREREQUISITES CHECK - Validates environment before deployment
#===============================================================================
# This function verifies:
#   1. Azure CLI is installed (for resource management)
#   2. Azure Developer CLI is installed (for deployment orchestration)
#   3. User is authenticated to Azure (or guides them through login)
#
# TRAINER TIP: This is a good time to explain the difference between
# Azure CLI (resource operations) and Azure Developer CLI (app deployment)
check_prerequisites() {
    print_section "📋 Checking Prerequisites"

    local missing=0

    # Detect OS for setup script recommendation
    local os_type="unknown"
    local setup_cmd=""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macOS"
        setup_cmd="./scripts/bash/setup-local-tools.sh"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        os_type="Linux"
        setup_cmd="./scripts/bash/setup-local-tools.sh"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        os_type="Windows (Git Bash)"
        setup_cmd=".\\scripts\\powershell\\setup-local-tools.ps1"
    fi

    echo -e "  ${CYAN}○${NC} Operating System: ${BOLD}$os_type${NC}"
    echo ""

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
        echo ""
        echo -e "${YELLOW}💡 Quick Setup:${NC} Run the automated setup script for your OS:"
        echo -e "   ${CYAN}$setup_cmd${NC}"
        echo ""
        echo -e "Or follow the manual setup guide:"
        echo -e "   ${CYAN}lessons/00-prerequisites/README.md${NC}"
        exit 1
    fi

    echo ""
    echo -e "${GREEN}All prerequisites satisfied!${NC}"

    #---------------------------------------------------------------------------
    # Handle Azure login if needed
    # The script supports both interactive browser login and device code flow
    # Device code is useful for Cloud Shell or headless environments
    #---------------------------------------------------------------------------
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
    fi
}

#===============================================================================
# SUBSCRIPTION SELECTION - Choose which Azure subscription to use
#===============================================================================
# WHAT IS AN AZURE SUBSCRIPTION?
#   A subscription is a billing and access boundary in Azure.
#   All resources are created within a subscription, and costs are billed
#   to the subscription.
#
# WHY SUBSCRIPTION SELECTION MATTERS:
#   - Many users have multiple subscriptions (personal, work, trial, etc.)
#   - Deploying to the wrong subscription can cause billing surprises
#   - Some subscriptions have quotas/restrictions (free tier limits)
#   - RBAC permissions differ between subscriptions
#
# SUBSCRIPTION TYPES YOU MIGHT SEE:
#   - Free Trial: $200 credit for 30 days, limited quotas
#   - Pay-As-You-Go: Standard billing, no commitment
#   - Visual Studio: Monthly credits for MSDN subscribers
#   - Enterprise Agreement: Corporate/volume licensing
#   - Azure for Students: $100 credit, no credit card required
#
# TRAINER TIP: This is a good time to discuss:
#   - How to check remaining credits (Cost Management)
#   - Subscription vs Resource Group vs Resource hierarchy
#   - How to request quota increases
#===============================================================================
select_subscription() {
    print_section "💳 Select Azure Subscription"

    echo -e "${CYAN}WHAT IS A SUBSCRIPTION?${NC}"
    echo "  A subscription is your billing account in Azure."
    echo "  All resources you create will be billed to this subscription."
    echo ""

    # Get list of subscriptions
    echo -e "${CYAN}Fetching your Azure subscriptions...${NC}"
    echo ""

    # Store subscriptions in an array
    local subs
    subs=$(az account list --query "[].{name:name, id:id, state:state, isDefault:isDefault}" -o json 2>/dev/null)

    if [ -z "$subs" ] || [ "$subs" = "[]" ]; then
        echo -e "${RED}No subscriptions found.${NC}"
        echo "Please ensure you have access to at least one Azure subscription."
        echo ""
        echo "If you need a subscription:"
        echo "  • Free Trial: https://azure.microsoft.com/free/"
        echo "  • Azure for Students: https://azure.microsoft.com/free/students/"
        exit 1
    fi

    # Count subscriptions
    local sub_count
    sub_count=$(echo "$subs" | jq 'length')

    if [ "$sub_count" -eq 1 ]; then
        # Only one subscription, use it automatically
        local sub_name
        local sub_id
        sub_name=$(echo "$subs" | jq -r '.[0].name')
        sub_id=$(echo "$subs" | jq -r '.[0].id')

        echo -e "  ${GREEN}✓${NC} Found 1 subscription: ${BOLD}$sub_name${NC}"
        echo ""
        SELECTED_SUBSCRIPTION_ID="$sub_id"
        SELECTED_SUBSCRIPTION_NAME="$sub_name"
    else
        # Multiple subscriptions, let user choose
        echo -e "  Found ${BOLD}$sub_count${NC} subscriptions:"
        echo ""

        # Display subscriptions with numbers
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        printf "  ${BOLD}%-3s %-45s %-10s${NC}\n" "#" "SUBSCRIPTION NAME" "STATE"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        local i=1
        while IFS= read -r sub; do
            local name=$(echo "$sub" | jq -r '.name')
            local state=$(echo "$sub" | jq -r '.state')
            local is_default=$(echo "$sub" | jq -r '.isDefault')

            local default_marker=""
            if [ "$is_default" = "true" ]; then
                default_marker=" ${GREEN}(current)${NC}"
            fi

            if [ "$state" = "Enabled" ]; then
                printf "  ${CYAN}%-3s${NC} %-45s ${GREEN}%-10s${NC}%b\n" "$i)" "$name" "$state" "$default_marker"
            else
                printf "  ${CYAN}%-3s${NC} %-45s ${YELLOW}%-10s${NC}\n" "$i)" "$name" "$state"
            fi
            ((i++))
        done < <(echo "$subs" | jq -c '.[]')

        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        # Get default subscription number for suggestion
        local default_num=1
        i=1
        while IFS= read -r sub; do
            local is_default=$(echo "$sub" | jq -r '.isDefault')
            if [ "$is_default" = "true" ]; then
                default_num=$i
                break
            fi
            ((i++))
        done < <(echo "$subs" | jq -c '.[]')

        while true; do
            echo -n "Select subscription [1-$sub_count] (default: $default_num): "
            read sub_choice

            # Use default if empty
            if [ -z "$sub_choice" ]; then
                sub_choice=$default_num
            fi

            # Validate input
            if [[ "$sub_choice" =~ ^[0-9]+$ ]] && [ "$sub_choice" -ge 1 ] && [ "$sub_choice" -le "$sub_count" ]; then
                # Get the selected subscription (0-indexed)
                local idx=$((sub_choice - 1))
                SELECTED_SUBSCRIPTION_ID=$(echo "$subs" | jq -r ".[$idx].id")
                SELECTED_SUBSCRIPTION_NAME=$(echo "$subs" | jq -r ".[$idx].name")
                break
            else
                echo -e "${RED}Invalid choice. Please enter a number between 1 and $sub_count.${NC}"
            fi
        done
    fi

    # Set the subscription as active
    echo ""
    echo -e "${CYAN}Setting active subscription...${NC}"
    az account set --subscription "$SELECTED_SUBSCRIPTION_ID"

    echo ""
    echo -e "${GREEN}✓ Using subscription: ${BOLD}$SELECTED_SUBSCRIPTION_NAME${NC}"
    echo -e "  ${CYAN}ID:${NC} ${SELECTED_SUBSCRIPTION_ID:0:8}..."
}

#===============================================================================
# PREFLIGHT CHECKS - Validate Azure readiness before deployment
#===============================================================================
# WHAT ARE PREFLIGHT CHECKS?
#   These are validation steps that run BEFORE we attempt deployment.
#   They catch common issues early, saving time and avoiding partial failures.
#
# WHAT WE CHECK:
#   1. Subscription state (is it enabled/active?)
#   2. Resource provider registration (are required services enabled?)
#   3. Quota availability (do we have enough vCPU quota?)
#   4. RBAC permissions (can we create resources?)
#
# WHY PREFLIGHT CHECKS MATTER:
#   - Failing after 10 minutes of deployment is frustrating
#   - Better to catch issues upfront with clear error messages
#   - Helps learners understand Azure's prerequisite requirements
#
# COMMON ISSUES DETECTED:
#   - "Microsoft.Compute not registered" → Need to register provider
#   - "QuotaExceeded" → Need to request quota increase
#   - "AuthorizationFailed" → Need Contributor role on subscription
#===============================================================================
run_preflight_checks() {
    print_section "🔍 Running Preflight Checks"

    echo -e "${CYAN}WHAT ARE PREFLIGHT CHECKS?${NC}"
    echo "  Validation steps that catch issues BEFORE deployment starts."
    echo "  This saves time by detecting problems early."
    echo ""

    local checks_passed=true
    local warnings=0

    #---------------------------------------------------------------------------
    # Check 1: Subscription State
    #---------------------------------------------------------------------------
    echo -e "${BOLD}1. Subscription Status${NC}"
    local sub_state
    sub_state=$(az account show --query state -o tsv 2>/dev/null)

    if [ "$sub_state" = "Enabled" ]; then
        echo -e "   ${GREEN}✓${NC} Subscription is active and enabled"
    else
        echo -e "   ${RED}✗${NC} Subscription state: $sub_state"
        echo -e "     ${CYAN}Your subscription may be suspended or disabled.${NC}"
        echo -e "     ${CYAN}Check: https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade${NC}"
        checks_passed=false
    fi

    #---------------------------------------------------------------------------
    # Check 2: Resource Providers
    #---------------------------------------------------------------------------
    echo ""
    echo -e "${BOLD}2. Resource Provider Registration${NC}"
    echo -e "   ${CYAN}(Azure services must be registered before use)${NC}"

    local providers=("Microsoft.Compute" "Microsoft.Storage" "Microsoft.Network" "Microsoft.Web" "Microsoft.ContainerRegistry")

    for provider in "${providers[@]}"; do
        local state
        state=$(az provider show --namespace "$provider" --query registrationState -o tsv 2>/dev/null)

        if [ "$state" = "Registered" ]; then
            echo -e "   ${GREEN}✓${NC} $provider"
        elif [ "$state" = "Registering" ]; then
            echo -e "   ${YELLOW}○${NC} $provider (registering, may take a few minutes)"
            ((warnings++))
        else
            echo -e "   ${YELLOW}○${NC} $provider - ${state:-Not found}"
            echo -e "     ${CYAN}Registering automatically...${NC}"
            az provider register --namespace "$provider" --wait 2>/dev/null &
            ((warnings++))
        fi
    done

    #---------------------------------------------------------------------------
    # Check 3: Quota Check (for VM-based lessons)
    #---------------------------------------------------------------------------
    echo ""
    echo -e "${BOLD}3. Compute Quota Check${NC}"
    echo -e "   ${CYAN}(Checking if you have vCPU quota for VMs)${NC}"

    # Check B-series quota (used by our VMs)
    local quota_info
    quota_info=$(az vm list-usage --location "$SELECTED_REGION" --query "[?contains(name.value, 'standardBSFamily')].{current:currentValue, limit:limit}" -o json 2>/dev/null)

    if [ -n "$quota_info" ] && [ "$quota_info" != "[]" ]; then
        local current=$(echo "$quota_info" | jq -r '.[0].current // 0')
        local limit=$(echo "$quota_info" | jq -r '.[0].limit // 0')
        local available=$((limit - current))

        if [ "$limit" -eq 0 ]; then
            echo -e "   ${YELLOW}⚠${NC} B-series vCPU quota: $current/$limit used (${RED}no quota${NC})"
            echo -e "     ${CYAN}Lessons 5 & 6 (VMs) may fail without quota.${NC}"
            echo -e "     ${CYAN}Request quota: https://aka.ms/azurequotarequest${NC}"
            ((warnings++))
        elif [ "$available" -lt 2 ]; then
            echo -e "   ${YELLOW}⚠${NC} B-series vCPU quota: $current/$limit used (${YELLOW}$available available${NC})"
            echo -e "     ${CYAN}You may not have enough quota for VM lessons.${NC}"
            ((warnings++))
        else
            echo -e "   ${GREEN}✓${NC} B-series vCPU quota: $current/$limit used (${GREEN}$available available${NC})"
        fi
    else
        echo -e "   ${YELLOW}○${NC} Could not check quota (may need permissions)"
        ((warnings++))
    fi

    #---------------------------------------------------------------------------
    # Check 4: RBAC Permissions
    #---------------------------------------------------------------------------
    echo ""
    echo -e "${BOLD}4. Permissions Check${NC}"
    echo -e "   ${CYAN}(Checking if you can create resources)${NC}"

    # Try to get role assignments for current user
    local user_id
    user_id=$(az ad signed-in-user show --query id -o tsv 2>/dev/null)

    if [ -n "$user_id" ]; then
        local roles
        roles=$(az role assignment list --assignee "$user_id" --query "[].roleDefinitionName" -o tsv 2>/dev/null | head -5)

        if [ -n "$roles" ]; then
            if echo "$roles" | grep -qiE "(owner|contributor)"; then
                echo -e "   ${GREEN}✓${NC} You have Owner/Contributor access"
            else
                echo -e "   ${YELLOW}⚠${NC} Found roles: $(echo $roles | tr '\n' ', ')"
                echo -e "     ${CYAN}You may need Contributor role to deploy resources.${NC}"
                ((warnings++))
            fi
        else
            echo -e "   ${YELLOW}○${NC} Could not determine role assignments"
            ((warnings++))
        fi
    else
        echo -e "   ${YELLOW}○${NC} Could not check permissions (Azure AD access needed)"
        ((warnings++))
    fi

    #---------------------------------------------------------------------------
    # Check 5: Region Availability
    #---------------------------------------------------------------------------
    echo ""
    echo -e "${BOLD}5. Region Availability${NC}"
    echo -e "   ${CYAN}(Checking if selected region is accessible)${NC}"

    local region_available
    region_available=$(az account list-locations --query "[?name=='$SELECTED_REGION'].name" -o tsv 2>/dev/null)

    if [ -n "$region_available" ]; then
        echo -e "   ${GREEN}✓${NC} Region '$SELECTED_REGION' is available"
    else
        echo -e "   ${RED}✗${NC} Region '$SELECTED_REGION' is not available"
        echo -e "     ${CYAN}This region may not be enabled for your subscription.${NC}"
        checks_passed=false
    fi

    #---------------------------------------------------------------------------
    # Summary
    #---------------------------------------------------------------------------
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ "$checks_passed" = false ]; then
        echo -e "${RED}  ✗ Preflight checks failed${NC}"
        echo ""
        echo "  Please address the issues above before continuing."
        echo "  Some resources may not deploy correctly."
        echo ""
        echo -n "  Continue anyway? (y/n): "
        read continue_anyway
        if [ "$continue_anyway" != "y" ] && [ "$continue_anyway" != "Y" ]; then
            echo ""
            echo -e "${YELLOW}Deployment cancelled. Please fix the issues and try again.${NC}"
            exit 1
        fi
    elif [ "$warnings" -gt 0 ]; then
        echo -e "${YELLOW}  ⚠ Preflight checks passed with $warnings warning(s)${NC}"
        echo ""
        echo "  Some checks had warnings. Deployment should work, but"
        echo "  certain lessons (especially VMs) may have issues."
        echo ""
        echo -n "  Continue with deployment? (y/n) [y]: "
        read continue_deploy
        if [ "$continue_deploy" = "n" ] || [ "$continue_deploy" = "N" ]; then
            echo ""
            echo -e "${YELLOW}Deployment cancelled.${NC}"
            exit 0
        fi
    else
        echo -e "${GREEN}  ✓ All preflight checks passed!${NC}"
    fi

    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

#===============================================================================
# REGION SELECTION - Choose Azure datacenter location
#===============================================================================
# WHAT IS AN AZURE REGION?
#   An Azure region is a set of datacenters deployed within a specific
#   geographic area. Azure has 60+ regions worldwide.
#
# WHY REGION MATTERS:
#   1. LATENCY: Closer regions = faster response times for your users
#   2. COMPLIANCE: Some data must stay in specific countries/regions (GDPR, etc.)
#   3. PRICING: Some regions are 10-20% cheaper than others
#   4. AVAILABILITY: Not all services available in all regions
#   5. CAPACITY: New accounts may have quota limits in popular regions
#
# AZURE REGION PAIRS:
#   Each region is paired with another 300+ miles away for disaster recovery.
#   Example: East US <-> West US, North Europe <-> West Europe
#
# FREE ACCOUNT CONSIDERATIONS:
#   - Some regions have better VM quota availability
#   - East US/East US 2 typically have the most capacity
#   - If deployment fails with "quota" error, try a different region
#
# TRAINER TIP: This is a good time to discuss:
#   - How to check service availability by region
#   - Latency testing with Azure Speed Test
#   - Cost differences between regions
#===============================================================================
select_region() {
    print_section "🌍 Select Azure Region"

    echo -e "${CYAN}WHAT IS A REGION?${NC}"
    echo "  An Azure region is a set of datacenters in a geographic area."
    echo "  Your resources will be physically located in these datacenters."
    echo ""
    echo -e "${CYAN}WHY THESE REGIONS?${NC}"
    echo "  These regions have the best capacity for Azure free/trial accounts."
    echo "  They're less likely to have quota issues for VMs and other resources."
    echo ""
    echo -e "  ${BOLD}North America (Recommended for training):${NC}"
    echo -e "    1) ${CYAN}East US${NC}          - Virginia (Largest Azure region, most services)"
    echo -e "    2) ${CYAN}East US 2${NC}        - Virginia (High availability, paired with Central US)"
    echo -e "    3) ${CYAN}West US 2${NC}        - Washington (Good for West Coast latency)"
    echo -e "    4) ${CYAN}Central US${NC}       - Iowa ${GREEN}(Best for Cosmos DB free tier)${NC}"
    echo -e "    5) ${CYAN}Canada Central${NC}   - Toronto (Data residency in Canada)"
    echo ""

    while true; do
        echo -n "Select region [1-5]: "
        read region_choice
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

#===============================================================================
# LESSON SELECTION - Choose which infrastructure to deploy
#===============================================================================
# Each lesson is self-contained with its own resource group.
# This makes it easy to:
#   - Deploy just what you need for the current session
#   - Clean up individual lessons without affecting others
#   - Demonstrate resource group isolation and organization
#
# WHAT GETS DEPLOYED (INFRASTRUCTURE OVERVIEW):
#
#   LESSON 02 - MANAGEMENT GROUPS:
#     Resources: 9 Management Groups in hierarchy
#     Why: Demonstrates governance at scale, how enterprises organize subscriptions
#     Bicep: Uses targetScope = 'managementGroup' (not subscription)
#
#   LESSON 03 - STORAGE SERVICES:
#     Resources: Storage Account with Blob containers, File shares, Queues, Tables
#     Why: Storage is foundational - nearly every Azure solution needs it
#     Bicep: /infra/modules/storage.bicep
#     Cost: FREE (within free tier limits: 5GB blob, 5GB file)
#
#   LESSON 04 - NETWORKING:
#     Resources: Virtual Network, Subnets, Network Security Groups (NSG)
#     Why: Networking is the backbone - VMs, databases, apps all need VNets
#     Bicep: /infra/modules/networking.bicep
#     Cost: FREE (VNets and NSGs have no charge, only data transfer)
#
#   LESSON 05 - COMPUTE (WINDOWS):
#     Resources: Windows Server VM, IIS, ASP.NET runtime, Public IP
#     Why: Shows traditional Windows workloads running in Azure IaaS
#     Bicep: /infra/modules/compute-windows.bicep
#     Cost: ~$15/month (B1s VM), FREE if you have $200 credits
#
#   LESSON 06 - COMPUTE (LINUX + KUBERNETES):
#     Resources: Ubuntu VM with MicroK8s pre-installed via cloud-init
#     Why: Demonstrates Linux VMs and intro to Kubernetes concepts
#     Bicep: /infra/modules/linux-microk8s.bicep
#     Cost: ~$10/month (B1s VM)
#
#   LESSON 07 - CONTAINER SERVICES:
#     Resources: Azure Container Registry (ACR), container images
#     Why: Shows container workflow - build, store, deploy
#     Bicep: /infra/modules/container-registry.bicep
#     Cost: ~$5/month (Basic ACR tier)
#
#   LESSON 08 - SERVERLESS:
#     Resources: Azure Functions (Consumption Plan), Storage Account
#     Why: Event-driven computing, pay-per-execution model
#     Bicep: /infra/modules/functions.bicep
#     Cost: FREE (1M executions/month free)
#
#   LESSON 09 - DATABASE SERVICES:
#     Resources: Cosmos DB (Serverless), Database, Container
#     Why: NoSQL, globally distributed, multi-model database
#     Bicep: /infra/modules/cosmosdb.bicep
#     Cost: Pay-per-request (very low for demos)
#
#   LESSON 11 - AI FOUNDRY:
#     Resources: Azure OpenAI, AI Hub, Model deployments
#     Why: Shows Azure's AI capabilities and GPT integration
#     Bicep: /infra/modules/ai-foundry.bicep
#     Cost: $1-5/day depending on usage
#
# COST GUIDE LEGEND:
#   FREE  = Works with free tier, no quota needed
#   QUOTA = Requires compute quota (vCPU allocation)
#   $$$   = Incurs costs even on free account
#===============================================================================
select_lesson() {
    print_section "📚 Select Lesson to Deploy"

    echo -e "${CYAN}HOW DEPLOYMENT WORKS:${NC}"
    echo "  1. You select a lesson below"
    echo "  2. Bicep files in /infra/modules/ define the Azure resources"
    echo "  3. azd compiles Bicep → ARM template → deploys to Azure"
    echo "  4. Resources appear in a dedicated resource group"
    echo ""
    echo -e "Each lesson deploys to its ${CYAN}own resource group${NC} for easy cleanup."
    echo -e "Lessons 1, 10, 12 are ${GREEN}portal/CLI demos${NC} - no Azure resources needed."
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  DAY 1 - FOUNDATIONS                                                         ${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}1)${NC} Introduction to Azure      ${GREEN}[NO RESOURCES]${NC} Portal & CLI basics"
    echo -e "   ${CYAN}2)${NC} Getting Started            ${YELLOW}[TENANT]${NC}       Management Groups & Policy"
    echo -e "   ${CYAN}3)${NC} Storage Services           ${GREEN}[FREE]${NC}         Blobs, queues, tables"
    echo -e "   ${CYAN}4)${NC} Networking Services        ${GREEN}[FREE]${NC}         VNets, subnets, NSGs"
    echo -e "   ${CYAN}5)${NC} Compute: Windows           ${YELLOW}[QUOTA: B1s]${NC}  Windows VM + App Service"
    echo -e "   ${CYAN}6)${NC} Compute: Linux & K8s       ${YELLOW}[QUOTA: B1s]${NC}  Ubuntu VM + MicroK8s"
    echo -e "   ${CYAN}7)${NC} Container Services         ${YELLOW}[~\$35/mo]${NC}      ACR + AKS + Hello World"
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
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ${CYAN}c)${NC} 🧹 Cleanup Resources       ${RED}[DELETE ALL]${NC}   Remove deployed resources"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
        echo -n "Select lesson [0-12, c=cleanup]: "
        read lesson_choice
        case $lesson_choice in
            0) SELECTED_LESSON=""; SSH_REQUIRED=1; WIN_PASSWORD_REQUIRED=1; DEPLOY_ALL=1; break;;
            1) SELECTED_LESSON="01"; NO_RESOURCES=1; break;;
            2) SELECTED_LESSON="02"; MGMT_GROUPS=1; break;;
            3) SELECTED_LESSON="03"; break;;
            4) SELECTED_LESSON="04"; break;;
            5) SELECTED_LESSON="05"; WIN_PASSWORD_REQUIRED=1; break;;
            6) SELECTED_LESSON="06"; SSH_REQUIRED=1; break;;
            7) SELECTED_LESSON="07"; break;;
            8) SELECTED_LESSON="08"; break;;
            9) SELECTED_LESSON="09"; break;;
            10) SELECTED_LESSON="10"; NO_RESOURCES=1; break;;
            11) SELECTED_LESSON="11"; break;;
            12) SELECTED_LESSON="12"; NO_RESOURCES=1; break;;
            c|C|cleanup) CLEANUP_MODE=1; break;;
            *) echo -e "${RED}Invalid choice. Please enter 0-12 or 'c' for cleanup.${NC}";;
        esac
    done

    # Handle cleanup from menu
    if [ "${CLEANUP_MODE:-0}" -eq 1 ]; then
        cleanup_resources
        exit 0
    fi

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

    # Handle Lesson 2 - Management Groups (requires tenant-level permissions)
    if [ "${MGMT_GROUPS:-0}" -eq 1 ]; then
        deploy_management_groups
        exit 0
    fi

    if [ -z "$SELECTED_LESSON" ]; then
        echo -e "${YELLOW}⚠️  Deploying ALL lessons will create multiple resource groups and may incur costs.${NC}"
        echo -n "Are you sure? (y/n): "
        read confirm
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

#===============================================================================
# ENVIRONMENT NAME - Unique identifier for your deployment
#===============================================================================
# The environment name becomes part of all resource names.
# This enables multiple learners to deploy simultaneously without conflicts.
#
# AZURE NAMING CONVENTIONS (BEST PRACTICES):
#   - Use consistent prefixes: rg- (resource group), st (storage), vm- (VM)
#   - Include environment: dev, test, prod
#   - Include region abbreviation: eus (East US), wus (West US)
#   - Keep names short but descriptive
#
# THIS COURSE USES:
#   Resource Group: rg-{env-name}-lesson{XX}-{purpose}
#   Example: rg-azlearn-john-lesson03-storage
#
# WHY NAMING MATTERS:
#   - Easy to identify resources in Azure Portal
#   - Enables filtering and searching
#   - Supports cost allocation and billing reports
#   - Required for automation scripts
#
# RESTRICTIONS:
#   - Storage accounts: 3-24 chars, lowercase letters and numbers only
#   - Resource groups: 1-90 chars, alphanumeric, underscores, hyphens
#   - Most resources: 1-63 chars, alphanumeric and hyphens
#===============================================================================
get_environment_name() {
    print_section "🏷️  Environment Name"

    echo -e "${CYAN}WHAT IS AN ENVIRONMENT NAME?${NC}"
    echo "  A unique prefix used to name all your Azure resources."
    echo "  This prevents naming conflicts if multiple learners deploy."
    echo ""
    echo -e "${CYAN}HOW IT'S USED:${NC}"
    echo "  Resource Group: rg-{name}-lesson03-storage"
    echo "  Storage Account: st{name}lesson03"
    echo "  Virtual Machine: vm-{name}-win-01"
    echo ""

    local default_name="azlearn-$(whoami | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c1-8)"
    echo -n "Environment name [$default_name]: "
    read env_name

    if [ -z "$env_name" ]; then
        ENV_NAME="$default_name"
    else
        # Sanitize: lowercase, remove special chars except hyphens
        ENV_NAME=$(echo "$env_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
    fi

    echo ""
    echo -e "${GREEN}Environment name: ${BOLD}$ENV_NAME${NC}"
    echo -e "${CYAN}Your resources will be named like: rg-$ENV_NAME-lesson03-storage${NC}"
}

#===============================================================================
# MANAGEMENT GROUPS DEPLOYMENT (Lesson 02)
#===============================================================================
# WHAT ARE MANAGEMENT GROUPS?
#   Management Groups provide a governance hierarchy above subscriptions.
#   They enable you to organize subscriptions and apply policies at scale.
#
# WHY MANAGEMENT GROUPS MATTER:
#   - Enterprise Governance: Apply policies to multiple subscriptions at once
#   - Cost Management: Aggregate costs across subscriptions
#   - Access Control: Assign RBAC at management group level
#   - Compliance: Enforce standards across the organization
#
# THE AZURE LANDING ZONE PATTERN:
#   This is Microsoft's recommended structure for enterprise Azure:
#
#   Root Management Group (Tenant Root Group)
#   ├── Platform (shared infrastructure)
#   │   ├── Identity (Azure AD, access control)
#   │   ├── Connectivity (hub networking, DNS)
#   │   └── Management (monitoring, automation)
#   ├── Workloads (business applications)
#   │   ├── Production (live workloads)
#   │   └── Non-Production (dev/test)
#   └── Sandbox (experimentation, no governance)
#
# BICEP NOTE:
#   Management Groups use targetScope = 'tenant' in Bicep.
#   They're created via Azure CLI here because they're tenant-level resources.
#
# REQUIREMENT: Tenant-level permissions (Global Admin or Management Group Contributor)
#===============================================================================
deploy_management_groups() {
    print_section "🏢 Deploying Management Groups"

    echo -e "${CYAN}WHAT YOU'RE DEPLOYING:${NC}"
    echo "  Management Groups create an organizational hierarchy above subscriptions."
    echo "  This follows the Azure Landing Zone pattern used by enterprises."
    echo ""
    echo -e "${YELLOW}⚠️  REQUIREMENT: Tenant-level permissions (Global Admin or similar)${NC}"
    echo ""
    echo -e "${CYAN}HIERARCHY BEING CREATED:${NC}"
    echo ""
    echo "  📁 mg-${ENV_NAME}-root (Organization Root)"
    echo "  ├── 📁 mg-${ENV_NAME}-platform     ← Shared infrastructure"
    echo "  │   ├── 📁 mg-${ENV_NAME}-identity      (Azure AD, RBAC)"
    echo "  │   ├── 📁 mg-${ENV_NAME}-connectivity  (Hub networking)"
    echo "  │   └── 📁 mg-${ENV_NAME}-management    (Monitoring, automation)"
    echo "  ├── 📁 mg-${ENV_NAME}-workloads    ← Business applications"
    echo "  │   ├── 📁 mg-${ENV_NAME}-prod         (Production)"
    echo "  │   └── 📁 mg-${ENV_NAME}-nonprod      (Dev/Test)"
    echo "  └── 📁 mg-${ENV_NAME}-sandbox      ← Experimentation"
    echo ""

    echo -n "Deploy Management Groups? (y/n): "
    read confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}Deployment cancelled.${NC}"
        exit 0
    fi

    echo ""
    echo -e "${CYAN}Deploying Management Groups via Azure CLI...${NC}"
    echo ""

    local mg_prefix="mg-${ENV_NAME}"
    local success=true

    # Level 1: Root
    echo "Creating root: ${mg_prefix}-root"
    az account management-group create \
        --name "${mg_prefix}-root" \
        --display-name "Organization Root" \
        --output none 2>/dev/null || success=false

    # Level 2: Platform, Workloads, Sandbox
    echo "Creating second-level groups..."
    for child in "platform" "workloads" "sandbox"; do
        # Cross-platform capitalize: works on both macOS (BSD) and Linux (GNU)
        display_name=$(echo "$child" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
        az account management-group create \
            --name "${mg_prefix}-${child}" \
            --display-name "$display_name" \
            --parent "${mg_prefix}-root" \
            --output none 2>/dev/null || true
        echo "  ✓ ${mg_prefix}-${child}"
    done

    # Level 3: Platform children
    echo "Creating Platform children..."
    for child in "identity" "connectivity" "management"; do
        # Cross-platform capitalize: works on both macOS (BSD) and Linux (GNU)
        display_name=$(echo "$child" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
        az account management-group create \
            --name "${mg_prefix}-${child}" \
            --display-name "$display_name" \
            --parent "${mg_prefix}-platform" \
            --output none 2>/dev/null || true
        echo "  ✓ ${mg_prefix}-${child}"
    done

    # Level 3: Workloads children
    echo "Creating Workloads children..."
    az account management-group create \
        --name "${mg_prefix}-prod" \
        --display-name "Production" \
        --parent "${mg_prefix}-workloads" \
        --output none 2>/dev/null || true
    echo "  ✓ ${mg_prefix}-prod"

    az account management-group create \
        --name "${mg_prefix}-nonprod" \
        --display-name "Non-Production" \
        --parent "${mg_prefix}-workloads" \
        --output none 2>/dev/null || true
    echo "  ✓ ${mg_prefix}-nonprod"

    if [ "$success" = true ]; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  ✅ Management Groups Created Successfully!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "View in Azure Portal:"
        echo "  https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade"
        echo ""
        echo -e "${YELLOW}To clean up Management Groups (delete in order):${NC}"
        echo -e "  ${CYAN}scripts/azure-cli/lesson-02-management-groups.sh --cleanup${NC}"
    else
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}  ❌ Deployment Failed${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Common issues:"
        echo "  • You need tenant-level permissions (Global Admin or similar)"
        echo "  • Your account may not have Management Group Contributor role"
        echo ""
        echo "Request permissions from your Azure AD administrator."
    fi
}

#===============================================================================
# MANAGEMENT GROUPS DEPLOYMENT (Silent version for Deploy ALL)
#===============================================================================
deploy_management_groups_silent() {
    echo ""
    echo -e "${CYAN}Deploying Management Groups via Azure CLI...${NC}"
    echo ""

    local mg_prefix="mg-${ENV_NAME}"

    # Level 1: Root
    echo "  Creating root: ${mg_prefix}-root"
    az account management-group create \
        --name "${mg_prefix}-root" \
        --display-name "Organization Root" \
        --output none 2>/dev/null || true

    # Level 2: Platform, Workloads, Sandbox
    echo "  Creating second-level groups..."
    az account management-group create \
        --name "${mg_prefix}-platform" \
        --display-name "Platform" \
        --parent "${mg_prefix}-root" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-platform"

    az account management-group create \
        --name "${mg_prefix}-workloads" \
        --display-name "Workloads" \
        --parent "${mg_prefix}-root" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-workloads"

    az account management-group create \
        --name "${mg_prefix}-sandbox" \
        --display-name "Sandbox" \
        --parent "${mg_prefix}-root" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-sandbox"

    # Level 3: Platform children
    echo "  Creating Platform children..."
    az account management-group create \
        --name "${mg_prefix}-identity" \
        --display-name "Identity" \
        --parent "${mg_prefix}-platform" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-identity"

    az account management-group create \
        --name "${mg_prefix}-connectivity" \
        --display-name "Connectivity" \
        --parent "${mg_prefix}-platform" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-connectivity"

    az account management-group create \
        --name "${mg_prefix}-management" \
        --display-name "Management" \
        --parent "${mg_prefix}-platform" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-management"

    # Level 3: Workloads children
    echo "  Creating Workloads children..."
    az account management-group create \
        --name "${mg_prefix}-prod" \
        --display-name "Production" \
        --parent "${mg_prefix}-workloads" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-prod"

    az account management-group create \
        --name "${mg_prefix}-nonprod" \
        --display-name "Non-Production" \
        --parent "${mg_prefix}-workloads" \
        --output none 2>/dev/null || true
    echo "    ✓ ${mg_prefix}-nonprod"

    echo ""
    echo -e "${GREEN}  ✅ Management Groups created (9 total)${NC}"
}

#===============================================================================
# WINDOWS PASSWORD SETUP (Lesson 05)
#===============================================================================
# Windows VMs require password authentication for RDP (Remote Desktop) access.
#
# AZURE PASSWORD REQUIREMENTS:
#   Azure enforces strong password complexity to prevent brute-force attacks:
#   - Minimum 12 characters (Azure requires 8, but 12+ is best practice)
#   - At least one uppercase letter (A-Z)
#   - At least one lowercase letter (a-z)
#   - At least one number (0-9)
#   - At least one special character (!@#$%^&*) - recommended
#
# SECURITY BEST PRACTICES (PRODUCTION):
#   For production workloads, passwords alone are NOT sufficient:
#   - Use Azure Bastion: Secure RDP/SSH without public IPs
#   - Use Just-in-Time (JIT) VM access: Time-limited access
#   - Use Azure AD authentication: MFA and conditional access
#   - Use Azure Key Vault: Store credentials securely
#
# TRAINER TIP: This is a good time to discuss:
#   - Why public IP + RDP is risky (port 3389 attacks)
#   - Azure Bastion as a secure alternative
#   - The shared responsibility model in cloud security
#===============================================================================
# Generate a secure random password that meets Azure requirements
generate_random_password() {
    # Azure requires: 12+ chars, uppercase, lowercase, number, special char
    local upper="ABCDEFGHJKLMNPQRSTUVWXYZ"
    local lower="abcdefghjkmnpqrstuvwxyz"
    local nums="23456789"
    local special="!@#\$%&*"

    # Build password with guaranteed character types at specific positions
    # This ensures complexity requirements are met without needing shuffle
    local pass=""

    # Start with one of each required type
    pass+="${upper:RANDOM%${#upper}:1}"
    pass+="${lower:RANDOM%${#lower}:1}"
    pass+="${nums:RANDOM%${#nums}:1}"
    pass+="${special:RANDOM%${#special}:1}"

    # Fill with more random characters from all sets
    local all="${upper}${lower}${nums}"
    for i in {1..8}; do
        pass+="${all:RANDOM%${#all}:1}"
    done

    # Add another special char and uppercase for good measure
    pass+="${special:RANDOM%${#special}:1}"
    pass+="${upper:RANDOM%${#upper}:1}"
    pass+="${lower:RANDOM%${#lower}:1}"
    pass+="${nums:RANDOM%${#nums}:1}"

    # Cross-platform shuffle: use awk with random sorting (works on macOS and Linux)
    if command -v shuf &> /dev/null; then
        echo "$pass" | fold -w1 | shuf | tr -d '\n'
    else
        # macOS fallback: use awk for shuffling
        echo "$pass" | fold -w1 | awk 'BEGIN{srand()} {print rand()"\t"$0}' | sort -n | cut -f2 | tr -d '\n'
    fi
}

setup_windows_password() {
    if [ "${WIN_PASSWORD_REQUIRED:-0}" -ne 1 ]; then
        return
    fi

    print_section "🔐 Windows VM Password Setup"

    echo -e "${CYAN}WHAT YOU'RE CONFIGURING:${NC}"
    echo "  Lesson 5 deploys a Windows Server VM with IIS web server."
    echo "  You'll use Remote Desktop (RDP) to connect to this VM."
    echo ""
    echo -e "${CYAN}WHY A PASSWORD?${NC}"
    echo "  Windows VMs use username/password for RDP authentication."
    echo "  In production, you'd use Azure Bastion or Azure AD instead."
    echo ""
    echo -e "${YELLOW}Password requirements (Azure enforced):${NC}"
    echo "  • At least 12 characters"
    echo "  • Contains uppercase (A-Z)"
    echo "  • Contains lowercase (a-z)"
    echo "  • Contains number (0-9)"
    echo "  • Special character recommended (!@#$%^&*)"
    echo ""

    echo -e "${CYAN}Password options:${NC}"
    echo "  1) Generate a secure random password (recommended)"
    echo "  2) Enter your own password"
    echo ""
    echo -n "Select option [1-2, default=1]: "
    read password_option
    password_option=${password_option:-1}
    echo ""

    if [ "$password_option" = "1" ]; then
        # Auto-generate password
        WINDOWS_PASSWORD=$(generate_random_password)
        echo -e "${GREEN}✓ Generated secure password.${NC}"
        echo ""
        echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  ${RED}IMPORTANT: SAVE THIS PASSWORD NOW!${YELLOW}                          ║${NC}"
        echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${YELLOW}║  Username: ${WHITE}azureuser${YELLOW}                                        ║${NC}"
        echo -e "${YELLOW}║  Password: ${WHITE}${WINDOWS_PASSWORD}${YELLOW}                      ║${NC}"
        echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}You'll need these credentials to RDP into your Windows VM.${NC}"
    else
        # Manual password entry
        while true; do
            echo -n "Enter password for Windows VM: "
            read -s WINDOWS_PASSWORD
            echo ""

            if [ ${#WINDOWS_PASSWORD} -lt 12 ]; then
                echo -e "${RED}Password must be at least 12 characters.${NC}"
                continue
            fi

            # Check for complexity (basic check)
            if ! echo "$WINDOWS_PASSWORD" | grep -q '[A-Z]'; then
                echo -e "${RED}Password must contain at least one uppercase letter.${NC}"
                continue
            fi
            if ! echo "$WINDOWS_PASSWORD" | grep -q '[a-z]'; then
                echo -e "${RED}Password must contain at least one lowercase letter.${NC}"
                continue
            fi
            if ! echo "$WINDOWS_PASSWORD" | grep -q '[0-9]'; then
                echo -e "${RED}Password must contain at least one number.${NC}"
                continue
            fi

            echo -n "Confirm password: "
            read -s WINDOWS_PASSWORD_CONFIRM
            echo ""

            if [ "$WINDOWS_PASSWORD" != "$WINDOWS_PASSWORD_CONFIRM" ]; then
                echo -e "${RED}Passwords do not match. Try again.${NC}"
                continue
            fi

            break
        done

        echo ""
        echo -e "${GREEN}✓ Windows password set.${NC}"
        echo ""
        echo -e "${YELLOW}💡 Remember your credentials:${NC}"
        echo "   Username: azureuser"
        echo "   Password: (the password you just entered)"
    fi
}

#===============================================================================
# SSH KEY SETUP (Lesson 06)
#===============================================================================
# Linux VMs use SSH key-based authentication (more secure than passwords).
#
# HOW SSH KEY AUTHENTICATION WORKS:
#   SSH uses asymmetric cryptography with a key pair:
#
#   ┌─────────────────────────────────────────────────────────────────────┐
#   │  PRIVATE KEY (id_ed25519)              PUBLIC KEY (id_ed25519.pub)  │
#   │  ─────────────────────────             ───────────────────────────  │
#   │  • Stays on YOUR machine               • Uploaded to Azure VM      │
#   │  • NEVER share this file               • Safe to share publicly    │
#   │  • Used to prove your identity         • Used to verify identity   │
#   │  • Located: ~/.ssh/id_ed25519          • Located: ~/.ssh/*.pub     │
#   └─────────────────────────────────────────────────────────────────────┘
#
# KEY TYPES:
#   - Ed25519: Modern, recommended (shorter keys, faster, more secure)
#   - RSA: Traditional, widely compatible (use 4096-bit minimum)
#
# THE SSH CONNECTION FLOW:
#   1. You run: ssh azureuser@<vm-ip>
#   2. VM sends a challenge encrypted with your public key
#   3. Your machine decrypts with private key and responds
#   4. VM verifies response → you're authenticated!
#
# AZURE SSH BEST PRACTICES:
#   - Use Ed25519 keys (ssh-keygen -t ed25519)
#   - Disable password authentication on VMs
#   - Use Azure Bastion for production (no public SSH exposure)
#   - Rotate keys periodically
#
# TRAINER TIP: This is a good time to explain:
#   - Why SSH keys are more secure than passwords
#   - How to use ssh-agent for key management
#   - Azure Bastion as a secure alternative to public SSH
#===============================================================================
setup_ssh_key() {
    if [ "${SSH_REQUIRED:-0}" -ne 1 ]; then
        return
    fi

    print_section "🔑 SSH Key Setup"

    echo -e "${CYAN}WHAT YOU'RE CONFIGURING:${NC}"
    echo "  Lesson 6 deploys an Ubuntu Linux VM with MicroK8s."
    echo "  You'll use SSH (Secure Shell) to connect to this VM."
    echo ""
    echo -e "${CYAN}WHY SSH KEYS?${NC}"
    echo "  SSH keys are more secure than passwords:"
    echo "  • Can't be guessed or brute-forced"
    echo "  • Private key never leaves your machine"
    echo "  • Can be protected with a passphrase"
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

        # Check if key exists and remove to avoid interactive prompt
        if [ -f "$HOME/.ssh/id_ed25519_azure" ]; then
            rm -f "$HOME/.ssh/id_ed25519_azure" "$HOME/.ssh/id_ed25519_azure.pub"
        fi

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

#===============================================================================
# DEPLOYMENT CONFIRMATION & EXECUTION
#===============================================================================
# This is where the actual Azure deployment happens!
#
# WHAT 'azd up' DOES BEHIND THE SCENES:
#
#   1. READS azure.yaml
#      - Project configuration file at repository root
#      - Defines project name, services, and infrastructure location
#
#   2. COMPILES BICEP TO ARM
#      - Input: /infra/main.bicep (and modules)
#      - Output: ARM JSON template
#      - Uses: Azure Bicep CLI (az bicep build)
#
#   3. VALIDATES TEMPLATE
#      - Checks syntax and resource availability
#      - Verifies you have permissions
#      - Estimates deployment time
#
#   4. CREATES RESOURCE GROUP
#      - Name pattern: rg-{env-name}-{lesson}
#      - Location: your selected region
#
#   5. DEPLOYS RESOURCES
#      - Sends template to Azure Resource Manager
#      - ARM creates resources in dependency order
#      - Progress shown in terminal
#
#   6. CAPTURES OUTPUTS
#      - Resource IDs, URLs, connection strings
#      - Stored in azd environment for later use
#
# COMMON DEPLOYMENT ERRORS:
#   - "QuotaExceeded": Request more vCPU quota or try different region
#   - "InvalidTemplateDeployment": Check Bicep syntax errors
#   - "AuthorizationFailed": Check RBAC permissions
#
# DEPLOYMENT TIME:
#   - Storage/Networking: 1-2 minutes
#   - VMs: 3-5 minutes
#   - AKS: 5-10 minutes
#   - AI Foundry: 5-10 minutes
#===============================================================================
confirm_and_deploy() {
    print_section "🚀 Ready to Deploy"

    echo -e "${CYAN}DEPLOYMENT SUMMARY:${NC}"
    echo ""
    echo -e "  Environment:  ${BOLD}$ENV_NAME${NC}"
    echo -e "  Region:       ${BOLD}$SELECTED_REGION${NC}"
    if [ -z "$SELECTED_LESSON" ]; then
        echo -e "  Lesson:       ${BOLD}All Lessons (02-09, 11)${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT'S BEING DEPLOYED:${NC}"
        echo ""
        echo -e "  ${YELLOW}Management Groups (9 total):${NC}"
        echo "    └─ Azure Landing Zone hierarchy for governance"
        echo ""
        echo -e "  ${YELLOW}Resource Groups & Infrastructure:${NC}"
        echo ""
        echo "    📦 rg-$ENV_NAME-lesson03-storage"
        echo "       └─ Storage Account (Blob, Files, Queues, Tables)"
        echo ""
        echo "    🌐 rg-$ENV_NAME-lesson04-networking"
        echo "       └─ VNet + Subnets + NSG (network security)"
        echo ""
        echo "    🖥️  rg-$ENV_NAME-lesson05-compute"
        echo "       └─ Windows Server VM + IIS + Public IP"
        echo ""
        echo "    🐧 rg-$ENV_NAME-lesson06-linux-k8s"
        echo "       └─ Ubuntu VM + MicroK8s (Kubernetes)"
        echo ""
        echo "    🐳 rg-$ENV_NAME-lesson07-containers"
        echo "       └─ Azure Container Registry (ACR)"
        echo ""
        echo "    ⚡ rg-$ENV_NAME-lesson08-serverless"
        echo "       └─ Azure Functions (Consumption Plan)"
        echo ""
        echo "    🗄️  rg-$ENV_NAME-lesson09-database"
        echo "       └─ Cosmos DB (Serverless NoSQL)"
        echo ""
        echo "    🤖 rg-$ENV_NAME-lesson11-ai-foundry"
        echo "       └─ Azure AI Hub + OpenAI models"
    elif [ "$SELECTED_LESSON" = "03" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 03 - Storage Services${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    How Azure Storage provides four types of cloud storage"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    📦 Resource Group: rg-$ENV_NAME-lesson03-storage"
        echo "    └─ Storage Account"
        echo "       ├─ Blob container (for unstructured data)"
        echo "       ├─ File share (SMB protocol)"
        echo "       ├─ Queue (message processing)"
        echo "       └─ Table (NoSQL key-value)"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/storage.bicep"
        echo -e "  ${GREEN}COST: FREE (within free tier limits)${NC}"
    elif [ "$SELECTED_LESSON" = "04" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 04 - Networking Services${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    How Azure Virtual Networks provide isolated networking"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    🌐 Resource Group: rg-$ENV_NAME-lesson04-networking"
        echo "    └─ Virtual Network (10.0.0.0/16)"
        echo "       ├─ Subnet: web-subnet (10.0.1.0/24)"
        echo "       ├─ Subnet: app-subnet (10.0.2.0/24)"
        echo "       ├─ Subnet: data-subnet (10.0.3.0/24)"
        echo "       └─ Network Security Group (firewall rules)"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/networking.bicep"
        echo -e "  ${GREEN}COST: FREE (VNets have no charge)${NC}"
    elif [ "$SELECTED_LESSON" = "05" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 05 - Windows Compute${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    How to run Windows Server workloads in Azure VMs"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    🖥️  Resource Group: rg-$ENV_NAME-lesson05-compute"
        echo "    ├─ Windows Server 2022 VM (Standard_B1s)"
        echo "    ├─ IIS Web Server (installed via extension)"
        echo "    ├─ Public IP Address (for RDP access)"
        echo "    └─ Network Security Group (RDP port 3389)"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/compute-windows.bicep"
        echo -e "  ${YELLOW}COST: ~\$15/month (B1s VM) - stop VM when not in use${NC}"
    elif [ "$SELECTED_LESSON" = "06" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 06 - Linux & Kubernetes${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    How to run Linux VMs and get started with Kubernetes"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    🐧 Resource Group: rg-$ENV_NAME-lesson06-linux-k8s"
        echo "    ├─ Ubuntu 22.04 LTS VM (Standard_B1s)"
        echo "    ├─ MicroK8s (lightweight Kubernetes) via cloud-init"
        echo "    ├─ Public IP Address (for SSH access)"
        echo "    └─ Network Security Group (SSH port 22)"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/linux-microk8s.bicep"
        echo -e "  ${YELLOW}COST: ~\$10/month (B1s VM) - stop VM when not in use${NC}"
    elif [ "$SELECTED_LESSON" = "07" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 07 - Container Services${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    How to build, store, and deploy container images"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    🐳 Resource Group: rg-$ENV_NAME-lesson07-containers"
        echo "    └─ Azure Container Registry (Basic tier)"
        echo "       └─ hello-container image (built after deployment)"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/container-registry.bicep"
        echo -e "  ${YELLOW}COST: ~\$5/month (Basic ACR tier)${NC}"
    elif [ "$SELECTED_LESSON" = "08" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 08 - Serverless (Azure Functions)${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    Event-driven computing with pay-per-execution pricing"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    ⚡ Resource Group: rg-$ENV_NAME-lesson08-serverless"
        echo "    ├─ Azure Functions App (Consumption Plan)"
        echo "    ├─ Storage Account (for function state)"
        echo "    └─ Application Insights (monitoring)"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/functions.bicep"
        echo -e "  ${GREEN}COST: FREE (1M executions/month free)${NC}"
    elif [ "$SELECTED_LESSON" = "09" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 09 - Database Services (Cosmos DB)${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    Globally distributed NoSQL database with multi-model support"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    🗄️  Resource Group: rg-$ENV_NAME-lesson09-database"
        echo "    └─ Cosmos DB Account (Serverless capacity)"
        echo "       └─ Database: essentials-db"
        echo "          └─ Container: items"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/cosmosdb.bicep"
        echo -e "  ${YELLOW}COST: Pay-per-request (very low for demos)${NC}"
    elif [ "$SELECTED_LESSON" = "11" ]; then
        echo -e "  Lesson:       ${BOLD}Lesson 11 - Azure AI Foundry${NC}"
        echo ""
        echo -e "  ${CYAN}WHAT YOU'LL LEARN:${NC}"
        echo "    Azure's AI platform with GPT models and AI services"
        echo ""
        echo -e "  ${CYAN}INFRASTRUCTURE BEING DEPLOYED:${NC}"
        echo "    🤖 Resource Group: rg-$ENV_NAME-lesson11-ai-foundry"
        echo "    ├─ Azure AI Hub (central AI management)"
        echo "    ├─ Azure OpenAI Service"
        echo "    │  └─ GPT model deployment"
        echo "    └─ Storage Account (for AI artifacts)"
        echo ""
        echo -e "  ${CYAN}BICEP FILE:${NC} /infra/modules/ai-foundry.bicep"
        echo -e "  ${RED}COST: \$1-5/day depending on usage${NC}"
    else
        echo -e "  Lesson:       ${BOLD}Lesson $SELECTED_LESSON${NC}"
        echo ""
        echo -e "  ${CYAN}Resource group to be created:${NC}"
        echo "    • rg-$ENV_NAME-lesson${SELECTED_LESSON}-*"
    fi
    echo ""

    echo -n "Proceed with deployment? (y/n): "
    read confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}Deployment cancelled.${NC}"
        exit 0
    fi

    # Initialize azd environment
    print_section "⚙️  Initializing Environment"

    echo -e "${CYAN}WHAT'S HAPPENING:${NC}"
    echo "  1. Creating/selecting azd environment '$ENV_NAME'"
    echo "  2. Setting Azure subscription and region"
    echo "  3. Configuring Bicep parameters"
    echo ""

    # Get current subscription ID
    local subscription_id
    subscription_id=$(az account show --query id -o tsv 2>/dev/null)

    if [ -z "$subscription_id" ]; then
        echo -e "${RED}Error: Could not get Azure subscription ID${NC}"
        echo "Please run 'az login' to authenticate."
        exit 1
    fi

    echo -e "Using subscription: ${BOLD}$(az account show --query name -o tsv)${NC}"

    # Create or select environment (use --no-prompt to avoid interactive prompts)
    if azd env list 2>/dev/null | grep -q "^$ENV_NAME "; then
        echo "Environment '$ENV_NAME' already exists, selecting it..."
        azd env select "$ENV_NAME"
    else
        echo "Creating new environment '$ENV_NAME'..."
        azd env new "$ENV_NAME" --no-prompt 2>/dev/null || azd env select "$ENV_NAME" 2>/dev/null || true
    fi

    # Set subscription and location
    azd env set AZURE_SUBSCRIPTION_ID "$subscription_id"
    azd env set AZURE_LOCATION "$SELECTED_REGION"

    if [ -n "$SELECTED_LESSON" ]; then
        azd env set LESSON_NUMBER "$SELECTED_LESSON"
    fi

    # Set Windows password if required
    if [ -n "$WINDOWS_PASSWORD" ]; then
        azd env set WINDOWS_ADMIN_PASSWORD "$WINDOWS_PASSWORD"
    fi

    # Set SSH key if required
    if [ -n "$SSH_PUBLIC_KEY" ]; then
        azd env set SSH_PUBLIC_KEY "$SSH_PUBLIC_KEY"
    fi

    echo ""
    echo -e "${GREEN}Environment configured successfully!${NC}"

    # Run deployment
    print_section "☁️  Deploying to Azure"

    echo -e "${CYAN}WHAT 'azd up' DOES:${NC}"
    echo "  1. Reads azure.yaml project configuration"
    echo "  2. Compiles Bicep files to ARM templates"
    echo "  3. Validates template with Azure Resource Manager"
    echo "  4. Creates resource group(s) in your subscription"
    echo "  5. Deploys resources in dependency order"
    echo "  6. Outputs resource URLs and connection info"
    echo ""
    echo -e "${YELLOW}Estimated time: 5-15 minutes depending on resources...${NC}"
    echo ""
    echo -e "${CYAN}You can watch the deployment in Azure Portal:${NC}"
    echo "  https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade"
    echo ""

    # Deploy Lesson 2 (Management Groups) via CLI if Deploy ALL
    if [ "${DEPLOY_ALL:-0}" -eq 1 ]; then
        echo -e "${CYAN}Step 1/2: Deploying Management Groups via Azure CLI...${NC}"
        deploy_management_groups_silent
        echo ""
        echo -e "${CYAN}Step 2/2: Deploying Lessons 3-9,11 via Bicep...${NC}"
    fi

    azd up

    # Post-deployment: Build container for Lesson 07
    if [ "$SELECTED_LESSON" = "07" ] || [ -z "$SELECTED_LESSON" ]; then
        build_hello_container
    fi
}

#===============================================================================
# POST-DEPLOYMENT: Build hello-container in ACR (Lesson 07)
#===============================================================================
build_hello_container() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_root="$(cd "${script_dir}/../.." && pwd)"
    local hello_app_dir="${repo_root}/lessons/07-container-services/src/hello-container"

    # Find the ACR name from deployed resources
    local acr_name=$(az acr list --query "[?contains(name, '${ENV_NAME}')].name" -o tsv 2>/dev/null | head -1)

    if [ -n "$acr_name" ] && [ -d "$hello_app_dir" ]; then
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}  Building hello-container in ACR...${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        az acr build \
            --registry "$acr_name" \
            --image hello-container:v1 \
            --file "${hello_app_dir}/Dockerfile" \
            "$hello_app_dir" \
            --no-logs

        local login_server=$(az acr show --name "$acr_name" --query loginServer -o tsv)
        echo -e "${GREEN}✓${NC} Image built: ${login_server}/hello-container:v1"
    fi
}

#===============================================================================
# COMPLETION MESSAGE - Summarizes what was deployed
#===============================================================================
# Shows learners:
#   - All resource groups that were created
#   - Next steps for following the lesson
#   - Commands for exploring and cleaning up
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

#===============================================================================
# MAIN EXECUTION - Entry point for the script
#===============================================================================
# THE DEPLOYMENT FLOW:
#
#   ┌─────────────────────────────────────────────────────────────────────────┐
#   │  STEP 1: PRINT BANNER                                                   │
#   │          Visual confirmation script is running                          │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 2: CHECK PREREQUISITES                                            │
#   │          Verify Azure CLI and azd are installed                         │
#   │          Login if not authenticated                                     │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 3: SELECT SUBSCRIPTION                         ← NEW!             │
#   │          Show all available subscriptions                               │
#   │          Let user choose which one to deploy to                         │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 4: GET ENVIRONMENT NAME                                           │
#   │          Unique identifier for resource naming                          │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 5: SELECT REGION                                                  │
#   │          Choose Azure datacenter location                               │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 6: RUN PREFLIGHT CHECKS                        ← NEW!             │
#   │          Validate subscription, quotas, providers, permissions          │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 7: SELECT LESSON                                                  │
#   │          Choose which infrastructure to deploy                          │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 8: SETUP CREDENTIALS (if needed)                                  │
#   │          Windows password for RDP / SSH key for Linux                   │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 9: CONFIRM AND DEPLOY                                             │
#   │          Final confirmation, run 'azd up'                               │
#   ├─────────────────────────────────────────────────────────────────────────┤
#   │  STEP 10: SHOW COMPLETION                                               │
#   │          Summary, next steps, cleanup instructions                      │
#   └─────────────────────────────────────────────────────────────────────────┘
#
#===============================================================================

#===============================================================================
# CLEANUP FUNCTION - Properly tear down all Azure resources
#===============================================================================
# WHY THIS EXISTS:
#   `azd down` has a known limitation with subscription-scoped deployments.
#   When main.bicep uses `targetScope = 'subscription'` and creates multiple
#   resource groups, azd down may fail to delete them properly.
#
# WHAT THIS DOES:
#   1. Finds all resource groups matching the environment name
#   2. Deletes them in parallel for faster cleanup
#   3. Cleans up management groups (Lesson 02)
#   4. Purges soft-deleted resources (Key Vaults, Cognitive Services)
#
# USAGE:
#   ./deploy.sh --cleanup                    # Interactive cleanup
#   ./deploy.sh --cleanup --env myenv        # Cleanup specific environment
#   ./deploy.sh --cleanup --env myenv --yes  # Non-interactive cleanup
#===============================================================================
cleanup_resources() {
    local force_yes="${FORCE_YES:-0}"

    print_banner
    print_section "🧹 Cleanup Azure Resources"

    echo -e "${CYAN}This will delete ALL Azure resources for environment '${ENV_NAME}'${NC}"
    echo ""

    # Find all resource groups matching this environment
    echo -e "${CYAN}Finding resource groups...${NC}"
    local resource_groups
    resource_groups=$(az group list --query "[?contains(name, 'rg-${ENV_NAME}-lesson')].name" -o tsv 2>/dev/null)

    # Find management groups
    local mg_root
    mg_root=$(az account management-group list --query "[?name=='mg-${ENV_NAME}-root'].name" -o tsv 2>/dev/null)

    if [ -z "$resource_groups" ] && [ -z "$mg_root" ]; then
        echo -e "${YELLOW}No resources found for environment '${ENV_NAME}'${NC}"
        echo ""
        echo "Tips:"
        echo "  • Check if you're logged into the correct subscription"
        echo "  • Verify the environment name is correct"
        echo "  • Run 'az group list' to see all resource groups"
        return 0
    fi

    echo ""
    echo -e "${BOLD}Resources to delete:${NC}"

    if [ -n "$resource_groups" ]; then
        echo ""
        echo -e "  ${YELLOW}Resource Groups:${NC}"
        echo "$resource_groups" | while read rg; do
            echo "    • $rg"
        done
    fi

    if [ -n "$mg_root" ]; then
        echo ""
        echo -e "  ${YELLOW}Management Groups:${NC}"
        echo "    • mg-${ENV_NAME}-root (and all children)"
    fi

    echo ""

    # Confirm deletion
    if [ "$force_yes" != "1" ]; then
        echo -e "${RED}⚠️  WARNING: This action cannot be undone!${NC}"
        echo ""
        echo -n "Are you sure you want to delete these resources? (yes/no): "
        read confirm
        if [ "$confirm" != "yes" ]; then
            echo ""
            echo -e "${YELLOW}Cleanup cancelled.${NC}"
            return 0
        fi
    fi

    echo ""

    # Delete resource groups in parallel
    if [ -n "$resource_groups" ]; then
        echo -e "${CYAN}Deleting resource groups (this may take several minutes)...${NC}"
        echo ""

        for rg in $resource_groups; do
            echo -e "  ${YELLOW}Deleting:${NC} $rg"
            az group delete --name "$rg" --yes --no-wait 2>/dev/null &
        done

        # Wait briefly for deletions to initiate
        sleep 3

        echo ""
        echo -e "${CYAN}Resource group deletions initiated. Waiting for completion...${NC}"
        echo ""

        # Wait for resource groups to be deleted (with timeout)
        local timeout=300  # 5 minutes
        local elapsed=0
        local interval=15

        while [ $elapsed -lt $timeout ]; do
            local remaining
            remaining=$(az group list --query "[?contains(name, 'rg-${ENV_NAME}-lesson')].name" -o tsv 2>/dev/null | wc -l | tr -d ' ')

            if [ "$remaining" -eq 0 ]; then
                echo -e "  ${GREEN}✅ All resource groups deleted!${NC}"
                break
            fi

            echo -e "  ⏳ $remaining resource group(s) still deleting... (${elapsed}s elapsed)"
            sleep $interval
            elapsed=$((elapsed + interval))
        done

        if [ $elapsed -ge $timeout ]; then
            echo ""
            echo -e "${YELLOW}⚠️  Timeout reached. Some resource groups may still be deleting.${NC}"
            echo -e "${YELLOW}    Check Azure Portal for status.${NC}"
        fi
    fi

    # Delete management groups
    if [ -n "$mg_root" ]; then
        echo ""
        echo -e "${CYAN}Deleting management groups...${NC}"
        echo ""

        local mg_prefix="mg-${ENV_NAME}"

        # Delete leaf nodes first
        for mg in "identity" "connectivity" "management" "prod" "nonprod"; do
            az account management-group delete --name "${mg_prefix}-${mg}" 2>/dev/null && \
                echo -e "  ${GREEN}✓${NC} Deleted ${mg_prefix}-${mg}" || true
        done

        # Delete second level
        for mg in "platform" "workloads" "sandbox"; do
            az account management-group delete --name "${mg_prefix}-${mg}" 2>/dev/null && \
                echo -e "  ${GREEN}✓${NC} Deleted ${mg_prefix}-${mg}" || true
        done

        # Delete root
        az account management-group delete --name "${mg_prefix}-root" 2>/dev/null && \
            echo -e "  ${GREEN}✓${NC} Deleted ${mg_prefix}-root" || true
    fi

    # Purge soft-deleted resources
    echo ""
    echo -e "${CYAN}Checking for soft-deleted resources to purge...${NC}"
    echo ""

    # Key Vaults
    local deleted_kvs
    deleted_kvs=$(az keyvault list-deleted --query "[?contains(name, '${ENV_NAME}')].name" -o tsv 2>/dev/null)

    if [ -n "$deleted_kvs" ]; then
        echo "  Purging soft-deleted Key Vaults..."
        for kv in $deleted_kvs; do
            az keyvault purge --name "$kv" 2>/dev/null && \
                echo -e "    ${GREEN}✓${NC} Purged $kv" || true
        done
    fi

    # Cognitive Services (AI Foundry)
    local deleted_cog
    deleted_cog=$(az cognitiveservices account list-deleted --query "[?contains(name, '${ENV_NAME}')].name" -o tsv 2>/dev/null)

    if [ -n "$deleted_cog" ]; then
        echo "  Purging soft-deleted Cognitive Services..."
        for cog in $deleted_cog; do
            local location
            location=$(az cognitiveservices account list-deleted --query "[?name=='$cog'].location" -o tsv 2>/dev/null)
            az cognitiveservices account purge --name "$cog" --resource-group "placeholder" --location "$location" 2>/dev/null && \
                echo -e "    ${GREEN}✓${NC} Purged $cog" || true
        done
    fi

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ Cleanup Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Verify cleanup in Azure Portal:"
    echo "  https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups"
    echo ""
}

#===============================================================================
# SHOW USAGE - Help text for command-line arguments
#===============================================================================
show_usage() {
    echo ""
    echo -e "${BOLD}Azure Essentials - Deployment Script${NC}"
    echo -e "${CYAN}Code to Cloud | www.codetocloud.io${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h           Show this help message"
    echo "  --cleanup            Remove all Azure resources for an environment"
    echo "  --env NAME           Specify environment name (default: azlearn-<username>)"
    echo "  --yes, -y            Skip confirmation prompts (use with --cleanup)"
    echo ""
    echo "Examples:"
    echo "  $0                   # Interactive deployment"
    echo "  $0 --cleanup         # Interactive cleanup (will prompt for env name)"
    echo "  $0 --cleanup --env myenv --yes  # Non-interactive cleanup"
    echo ""
    echo "For more information, see:"
    echo "  lessons/00-prerequisites/README.md"
    echo "  SCRIPTS.md"
    echo ""
}

main() {
    # Step 1: Show banner
    print_banner

    # Step 2: Check prerequisites (tools installed, login if needed)
    check_prerequisites

    # Step 3: Select Azure subscription
    select_subscription

    # Step 4: Get environment name for resource naming
    get_environment_name

    # Step 5: Select Azure region
    select_region

    # Step 6: Run preflight checks (validate before deployment)
    run_preflight_checks

    # Step 7: Select which lesson to deploy
    select_lesson

    # Step 8: Setup credentials if needed (Windows password, SSH key)
    setup_windows_password
    setup_ssh_key

    # Step 9: Confirm and deploy via azd
    confirm_and_deploy

    # Step 10: Show completion summary
    show_completion
}

#===============================================================================
# SCRIPT ENTRY POINT
#===============================================================================
# Parse command-line arguments
CLEANUP_MODE=0
FORCE_YES=0
CUSTOM_ENV=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        --cleanup)
            CLEANUP_MODE=1
            shift
            ;;
        --env)
            CUSTOM_ENV="$2"
            shift 2
            ;;
        --yes|-y)
            FORCE_YES=1
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Handle cleanup mode
if [ "$CLEANUP_MODE" -eq 1 ]; then
    print_banner
    check_prerequisites

    # If --yes flag is set, use current subscription without prompting
    if [ "$FORCE_YES" -eq 1 ]; then
        SELECTED_SUBSCRIPTION_NAME=$(az account show --query name -o tsv 2>/dev/null)
        SELECTED_SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null)
        echo -e "${GREEN}Using current subscription: ${BOLD}$SELECTED_SUBSCRIPTION_NAME${NC}"
    else
        select_subscription
    fi

    if [ -n "$CUSTOM_ENV" ]; then
        ENV_NAME="$CUSTOM_ENV"
        echo -e "${GREEN}Using environment: ${BOLD}$ENV_NAME${NC}"
    else
        get_environment_name
    fi

    export FORCE_YES
    cleanup_resources
    exit 0
fi

# Normal deployment flow
main "$@"
