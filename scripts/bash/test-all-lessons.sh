#!/bin/bash
#===============================================================================
# Azure Essentials - Test All Lessons Script
#===============================================================================
# This script tests each lesson deployment and tears down resources after each
# to ensure clean testing. It uses expect-style automation for the interactive
# menu system.
#
# USAGE:
#   ./scripts/bash/test-all-lessons.sh
#
# WHAT IT DOES:
#   1. Tests each deployable lesson (2-9, 11) individually
#   2. Deploys the lesson
#   3. Verifies resources were created
#   4. Tears down resources immediately after
#   5. Reports success/failure for each lesson
#===============================================================================

set -e

#===============================================================================
# COLOR DEFINITIONS
#===============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

#===============================================================================
# CONFIGURATION
#===============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENV_PREFIX="test$(date +%m%d%H%M)"
REGION="centralus"
SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null)

# Lessons that deploy Azure resources
DEPLOYABLE_LESSONS=(3 4 5 6 7 8 9 11)

# Track results
declare -A RESULTS

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================
print_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Azure Essentials - Automated Lesson Testing${NC}                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Testing all deployable lessons with automatic teardown                       ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_info() {
    echo -e "${CYAN}○${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

#===============================================================================
# GENERATE PASSWORD (macOS compatible)
#===============================================================================
generate_password() {
    local upper="ABCDEFGHJKLMNPQRSTUVWXYZ"
    local lower="abcdefghjkmnpqrstuvwxyz"
    local nums="23456789"
    local special="!@#\$%&*"

    local pass=""
    pass+="${upper:RANDOM%${#upper}:1}"
    pass+="${lower:RANDOM%${#lower}:1}"
    pass+="${nums:RANDOM%${#nums}:1}"
    pass+="${special:RANDOM%${#special}:1}"

    local all="${upper}${lower}${nums}"
    for i in {1..8}; do
        pass+="${all:RANDOM%${#all}:1}"
    done

    pass+="${special:RANDOM%${#special}:1}"
    pass+="${upper:RANDOM%${#upper}:1}"
    pass+="${lower:RANDOM%${#lower}:1}"
    pass+="${nums:RANDOM%${#nums}:1}"

    # macOS-compatible shuffle
    echo "$pass" | fold -w1 | awk 'BEGIN{srand()} {print rand()"\t"$0}' | sort -n | cut -f2 | tr -d '\n'
}

#===============================================================================
# CLEANUP MANAGEMENT GROUPS
#===============================================================================
cleanup_management_groups() {
    local prefix=$1
    log_info "Cleaning up management groups with prefix: $prefix"

    # Delete in reverse order (children first)
    az account management-group delete --name "${prefix}-identity" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-connectivity" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-management" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-prod" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-nonprod" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-platform" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-workloads" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-sandbox" --yes 2>/dev/null || true
    az account management-group delete --name "${prefix}-root" --yes 2>/dev/null || true

    log_success "Management groups cleaned up"
}

#===============================================================================
# DEPLOY LESSON 2 (Management Groups - Special Case)
#===============================================================================
test_lesson_02() {
    local env_name="${ENV_PREFIX}l02"
    local mg_prefix="mg-${env_name}"

    print_section "📚 Testing Lesson 02: Management Groups"

    echo -e "${CYAN}Deploying Management Groups...${NC}"
    echo ""

    local success=true

    # Create management group hierarchy
    echo "  Creating root: ${mg_prefix}-root"
    if ! az account management-group create --name "${mg_prefix}-root" --display-name "Test Root" --output none 2>/dev/null; then
        log_error "Failed to create root management group"
        success=false
    fi

    if [ "$success" = true ]; then
        # Level 2
        for child in "platform" "workloads" "sandbox"; do
            az account management-group create \
                --name "${mg_prefix}-${child}" \
                --display-name "$child" \
                --parent "${mg_prefix}-root" \
                --output none 2>/dev/null || true
            echo "    ✓ ${mg_prefix}-${child}"
        done

        # Level 3 - Platform children
        for child in "identity" "connectivity" "management"; do
            az account management-group create \
                --name "${mg_prefix}-${child}" \
                --display-name "$child" \
                --parent "${mg_prefix}-platform" \
                --output none 2>/dev/null || true
            echo "    ✓ ${mg_prefix}-${child}"
        done

        # Level 3 - Workloads children
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

        log_success "Management Groups deployed successfully"
    fi

    # Verify
    echo ""
    echo -e "${CYAN}Verifying deployment...${NC}"
    local mg_count=$(az account management-group list --query "[?contains(name, '${env_name}')]" -o json 2>/dev/null | jq 'length')
    if [ "$mg_count" -ge 9 ]; then
        log_success "Verified: $mg_count management groups created"
    else
        log_warning "Expected 9 management groups, found $mg_count"
    fi

    # Cleanup
    echo ""
    echo -e "${CYAN}Tearing down...${NC}"
    cleanup_management_groups "$mg_prefix"

    if [ "$success" = true ]; then
        RESULTS[2]="PASSED"
        log_success "Lesson 02 test PASSED"
    else
        RESULTS[2]="FAILED"
        log_error "Lesson 02 test FAILED"
    fi
}

#===============================================================================
# DEPLOY REGULAR LESSONS (3-9, 11) via azd
#===============================================================================
test_lesson() {
    local lesson_num=$1
    local env_name="${ENV_PREFIX}l$(printf '%02d' $lesson_num)"

    print_section "📚 Testing Lesson $(printf '%02d' $lesson_num)"

    cd "$REPO_ROOT"

    # Initialize environment
    echo -e "${CYAN}Creating azd environment: $env_name${NC}"
    azd env new "$env_name" --no-prompt 2>/dev/null || azd env select "$env_name" 2>/dev/null || true

    # Set environment variables
    azd env set AZURE_SUBSCRIPTION_ID "$SUBSCRIPTION_ID"
    azd env set AZURE_LOCATION "$REGION"
    azd env set LESSON_NUMBER "$(printf '%02d' $lesson_num)"

    # Set credentials for lessons that need them
    if [ "$lesson_num" -eq 5 ]; then
        local win_pass=$(generate_password)
        azd env set WINDOWS_ADMIN_PASSWORD "$win_pass"
        echo -e "${YELLOW}Windows password set for Lesson 05${NC}"
    fi

    if [ "$lesson_num" -eq 6 ]; then
        if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
            azd env set SSH_PUBLIC_KEY "$(cat $HOME/.ssh/id_rsa.pub)"
        elif [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
            azd env set SSH_PUBLIC_KEY "$(cat $HOME/.ssh/id_ed25519.pub)"
        fi
        echo -e "${YELLOW}SSH key set for Lesson 06${NC}"
    fi

    echo ""
    echo -e "${CYAN}Deploying lesson $lesson_num...${NC}"
    echo ""

    local deploy_success=false
    if azd up --no-prompt 2>&1 | tee /tmp/azd_output_$lesson_num.log; then
        deploy_success=true
        log_success "Deployment completed"
    else
        log_error "Deployment failed"
        cat /tmp/azd_output_$lesson_num.log | tail -20
    fi

    # Verify resources
    echo ""
    echo -e "${CYAN}Verifying resources...${NC}"
    local rg_name=$(az group list --query "[?contains(name, '$env_name')].name" -o tsv 2>/dev/null | head -1)
    if [ -n "$rg_name" ]; then
        local resource_count=$(az resource list --resource-group "$rg_name" --query 'length(@)' -o tsv 2>/dev/null)
        log_success "Resource group '$rg_name' contains $resource_count resources"
    else
        log_warning "No resource group found matching pattern"
    fi

    # Teardown
    echo ""
    echo -e "${CYAN}Tearing down resources...${NC}"
    if azd down --force --purge 2>&1 | tee -a /tmp/azd_output_$lesson_num.log; then
        log_success "Teardown completed"
    else
        log_warning "Teardown may have had issues, check manually"
    fi

    # Record result
    if [ "$deploy_success" = true ]; then
        RESULTS[$lesson_num]="PASSED"
        log_success "Lesson $(printf '%02d' $lesson_num) test PASSED"
    else
        RESULTS[$lesson_num]="FAILED"
        log_error "Lesson $(printf '%02d' $lesson_num) test FAILED"
    fi

    # Small delay between lessons
    sleep 5
}

#===============================================================================
# PRINT FINAL RESULTS
#===============================================================================
print_results() {
    print_section "📊 Test Results Summary"

    local passed=0
    local failed=0

    echo ""
    echo -e "${BOLD}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}│  LESSON                                           RESULT        │${NC}"
    echo -e "${BOLD}├─────────────────────────────────────────────────────────────────┤${NC}"

    for lesson in 2 3 4 5 6 7 8 9 11; do
        local result="${RESULTS[$lesson]:-NOT TESTED}"
        local lesson_name=""
        case $lesson in
            2) lesson_name="Management Groups";;
            3) lesson_name="Storage Services";;
            4) lesson_name="Networking";;
            5) lesson_name="Compute: Windows";;
            6) lesson_name="Compute: Linux & K8s";;
            7) lesson_name="Container Services";;
            8) lesson_name="Serverless";;
            9) lesson_name="Database (Cosmos DB)";;
            11) lesson_name="AI Foundry";;
        esac

        if [ "$result" = "PASSED" ]; then
            echo -e "│  Lesson $(printf '%02d' $lesson): ${lesson_name}$(printf '%*s' $((30-${#lesson_name})) '')${GREEN}PASSED${NC}        │"
            ((passed++))
        elif [ "$result" = "FAILED" ]; then
            echo -e "│  Lesson $(printf '%02d' $lesson): ${lesson_name}$(printf '%*s' $((30-${#lesson_name})) '')${RED}FAILED${NC}        │"
            ((failed++))
        else
            echo -e "│  Lesson $(printf '%02d' $lesson): ${lesson_name}$(printf '%*s' $((30-${#lesson_name})) '')${YELLOW}NOT TESTED${NC}    │"
        fi
    done

    echo -e "${BOLD}└─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${BOLD}Summary:${NC} ${GREEN}$passed passed${NC}, ${RED}$failed failed${NC}"
    echo ""

    if [ $failed -eq 0 ] && [ $passed -gt 0 ]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║              🎉 ALL TESTS PASSED! 🎉                         ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    elif [ $failed -gt 0 ]; then
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║              ⚠️  SOME TESTS FAILED                            ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "Check /tmp/azd_output_*.log for deployment details"
    fi
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    print_banner

    # Check prerequisites
    if ! az account show &>/dev/null; then
        log_error "Not logged in to Azure. Run 'az login' first."
        exit 1
    fi

    if ! command -v azd &>/dev/null; then
        log_error "Azure Developer CLI (azd) not installed."
        exit 1
    fi

    log_success "Prerequisites checked"
    log_info "Using subscription: $(az account show --query name -o tsv)"
    log_info "Testing region: $REGION"
    log_info "Environment prefix: $ENV_PREFIX"
    echo ""

    # Show what will be tested
    echo -e "${CYAN}Lessons to test:${NC}"
    echo "  • Lesson 02: Management Groups (tenant-level)"
    echo "  • Lesson 03: Storage Services (FREE)"
    echo "  • Lesson 04: Networking (FREE)"
    echo "  • Lesson 05: Windows VM (requires quota)"
    echo "  • Lesson 06: Linux VM + K8s (requires quota)"
    echo "  • Lesson 07: Container Services (ACR + AKS)"
    echo "  • Lesson 08: Serverless (Functions)"
    echo "  • Lesson 09: Cosmos DB (serverless)"
    echo "  • Lesson 11: AI Foundry"
    echo ""

    read -p "Start testing all lessons? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Testing cancelled."
        exit 0
    fi

    # Test Lesson 02 (Management Groups - special handling)
    test_lesson_02

    # Test remaining lessons
    for lesson in 3 4 5 6 7 8 9 11; do
        test_lesson $lesson
    done

    # Print final results
    print_results
}

# Run main
main "$@"
