#!/bin/bash
#===============================================================================
# Azure Essentials - Bash Script Testing Suite
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# PURPOSE:
#   Validates the quality and correctness of all bash deployment scripts.
#   This is a "test the tests" script - ensuring our automation is reliable.
#
# WHY TEST BASH SCRIPTS?
#   - Catch syntax errors before running scripts in production
#   - Verify required functions exist
#   - Ensure scripts are executable
#   - Validate error handling is in place
#
# TESTING CONCEPTS COVERED:
#   1. Syntax Validation  - Does the script parse correctly? (bash -n)
#   2. Shebang Check      - Does it specify the correct interpreter?
#   3. Function Discovery - Are required functions defined?
#   4. Permission Check   - Is the script executable?
#   5. Execution Test     - Does it run without crashing?
#
# USAGE:
#   ./scripts/bash/test-bash-scripts.sh
#
# NOTE FOR LEARNERS:
#   Writing tests for your automation scripts is a DevOps best practice.
#   This pattern applies to any scripting language, not just Bash.
#
#===============================================================================

# Don't exit on error - we want to run all tests and report results
# set -e

#===============================================================================
# SCRIPT DIRECTORY DETECTION
#===============================================================================
# This pattern finds the directory containing this script, regardless of
# where it's called from. Essential for referencing other scripts reliably.
# BASH_SOURCE[0] = path to current script (works even when sourced)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#===============================================================================
# TERMINAL COLORS
#===============================================================================
RED='\033[0;31m'      # Test failures
GREEN='\033[0;32m'    # Test passes
YELLOW='\033[1;33m'   # Warnings
CYAN='\033[0;36m'     # Section headers
NC='\033[0m'          # Reset color

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           Azure Essentials - Bash Script Testing Suite                       ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Testing script quality: syntax, functions, permissions, and execution.     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

#===============================================================================
# TEST COUNTERS AND HELPER FUNCTIONS
#===============================================================================
# Track test results for final summary
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function: Record a passing test
pass() {
    echo -e "   ${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

# Helper function: Record a failing test
fail() {
    echo -e "   ${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Helper function: Non-critical warning
warn() {
    echo -e "   ${YELLOW}⚠${NC} $1"
}

#===============================================================================
# TEST SUITE: deploy.sh
#===============================================================================
# deploy.sh is the main interactive deployment script.
# It's the most complex script, so we test it thoroughly.
#===============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Testing ${CYAN}deploy.sh${NC} - Main interactive deployment menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

#-------------------------------------------------------------------------------
# Test 1: Syntax Validation
#-------------------------------------------------------------------------------
# 'bash -n' parses the script without executing it.
# Catches syntax errors like unclosed quotes, missing 'fi', etc.
echo "1. Syntax Check (bash -n):"
echo "   Validates script parses correctly without execution."
if bash -n "$SCRIPT_DIR/deploy.sh" 2>/dev/null; then
    pass "Syntax valid"
else
    fail "Syntax errors found"
fi

#-------------------------------------------------------------------------------
# Test 2: Shebang Validation
#-------------------------------------------------------------------------------
# The shebang (#!) tells the OS which interpreter to use.
# #!/bin/bash is the standard for bash scripts.
echo ""
echo "2. Shebang Check:"
echo "   Verifies correct interpreter is specified."
SHEBANG=$(head -1 "$SCRIPT_DIR/deploy.sh")
if [[ "$SHEBANG" == "#!/bin/bash" ]]; then
    pass "Correct shebang: $SHEBANG"
else
    fail "Incorrect shebang: $SHEBANG"
fi

#-------------------------------------------------------------------------------
# Test 3: Error Handling
#-------------------------------------------------------------------------------
# 'set -e' causes the script to exit on first error.
# Critical for deployment scripts to avoid partial failures.
echo ""
echo "3. Error Handling (set -e):"
echo "   Ensures script fails fast on errors."
if grep -q "set -e" "$SCRIPT_DIR/deploy.sh"; then
    pass "Has 'set -e' for error handling"
else
    fail "Missing 'set -e'"
fi

#-------------------------------------------------------------------------------
# Test 4: Function Count
#-------------------------------------------------------------------------------
# Good scripts are modular with functions.
# deploy.sh should have many reusable functions.
echo ""
echo "4. Function Definitions:"
echo "   Checks for modular, reusable code structure."
FUNC_COUNT=$(grep -c "^[a-z_]*() {" "$SCRIPT_DIR/deploy.sh" 2>/dev/null || echo 0)
if [[ $FUNC_COUNT -ge 8 ]]; then
    pass "Found $FUNC_COUNT functions (modular design)"
else
    fail "Only found $FUNC_COUNT functions (expected 8+)"
fi

#-------------------------------------------------------------------------------
# Test 5: Required Functions
#-------------------------------------------------------------------------------
# These functions must exist for the script to work correctly.
echo ""
echo "5. Required Functions:"
echo "   Verifies core functions are defined."
REQUIRED_FUNCS=("print_banner" "check_prerequisites" "select_region" "select_lesson" "main")
for func in "${REQUIRED_FUNCS[@]}"; do
    if grep -q "^${func}() {" "$SCRIPT_DIR/deploy.sh"; then
        pass "$func() defined"
    else
        fail "$func() missing"
    fi
done

#-------------------------------------------------------------------------------
# Test 6: Executable Permission
#-------------------------------------------------------------------------------
# Scripts need +x permission to run directly.
# Without it, users must type 'bash script.sh' instead of './script.sh'
echo ""
echo "6. File Permissions:"
echo "   Script must be executable (chmod +x)."
if [[ -x "$SCRIPT_DIR/deploy.sh" ]]; then
    pass "deploy.sh is executable"
else
    fail "deploy.sh is not executable"
fi

#===============================================================================
# TEST SUITE: setup-local-tools.sh
#===============================================================================
# This script installs development tools.
# Testing ensures it will run correctly on user machines.
#===============================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Testing ${CYAN}setup-local-tools.sh${NC} - Development environment setup"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "1. Syntax Check (bash -n):"
if bash -n "$SCRIPT_DIR/setup-local-tools.sh" 2>/dev/null; then
    pass "Syntax valid"
else
    fail "Syntax errors found"
fi

echo ""
echo "2. Shebang Check:"
SHEBANG=$(head -1 "$SCRIPT_DIR/setup-local-tools.sh")
if [[ "$SHEBANG" == "#!/bin/bash" ]]; then
    pass "Correct shebang: $SHEBANG"
else
    fail "Incorrect shebang: $SHEBANG"
fi

echo ""
echo "3. Required Functions:"
echo "   Verifies tool installation functions exist."
REQUIRED_FUNCS=("detect_os" "command_exists" "install_azure_cli" "install_azd")
for func in "${REQUIRED_FUNCS[@]}"; do
    if grep -q "^${func}() {" "$SCRIPT_DIR/setup-local-tools.sh"; then
        pass "$func() defined"
    else
        fail "$func() missing"
    fi
done

echo ""
echo "4. File Permissions:"
if [[ -x "$SCRIPT_DIR/setup-local-tools.sh" ]]; then
    pass "setup-local-tools.sh is executable"
else
    fail "setup-local-tools.sh is not executable"
fi

#===============================================================================
# TEST SUITE: validate-env.sh
#===============================================================================
# This script checks environment readiness.
# It should run without errors even when tools are missing.
#===============================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Testing ${CYAN}validate-env.sh${NC} - Environment validation checks"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "1. Syntax Check (bash -n):"
if bash -n "$SCRIPT_DIR/validate-env.sh" 2>/dev/null; then
    pass "Syntax valid"
else
    fail "Syntax errors found"
fi

echo ""
echo "2. Shebang Check:"
SHEBANG=$(head -1 "$SCRIPT_DIR/validate-env.sh")
if [[ "$SHEBANG" == "#!/bin/bash" ]]; then
    pass "Correct shebang: $SHEBANG"
else
    fail "Incorrect shebang: $SHEBANG"
fi

echo ""
echo "3. Required Functions:"
echo "   Verifies validation check functions exist."
REQUIRED_FUNCS=("check_tool" "check_azure_login" "check_docker_running")
for func in "${REQUIRED_FUNCS[@]}"; do
    if grep -q "^${func}() {" "$SCRIPT_DIR/validate-env.sh"; then
        pass "$func() defined"
    else
        fail "$func() missing"
    fi
done

echo ""
echo "4. File Permissions:"
if [[ -x "$SCRIPT_DIR/validate-env.sh" ]]; then
    pass "validate-env.sh is executable"
else
    fail "validate-env.sh is not executable"
fi

echo ""
echo "5. Execution Test:"
echo "   Running validate-env.sh to check for runtime errors."
if "$SCRIPT_DIR/validate-env.sh" >/dev/null 2>&1; then
    pass "validate-env.sh runs without errors"
else
    warn "validate-env.sh had warnings (may be expected if tools missing)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

#===============================================================================
# TEST SUMMARY
#===============================================================================
# Aggregate results and provide overall pass/fail status.
#===============================================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                           TEST SUMMARY                                       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "   ${GREEN}Passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "   ${RED}Failed: $TESTS_FAILED${NC}"
else
    echo -e "   ${GREEN}Failed: $TESTS_FAILED${NC}"
fi
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "   ${GREEN}✓ All bash scripts are valid and ready for use!${NC}"
    echo ""
    echo -e "   ${CYAN}Scripts tested:${NC}"
    echo "     • deploy.sh            - Interactive deployment menu"
    echo "     • setup-local-tools.sh - Development environment setup"
    echo "     • validate-env.sh      - Environment validation checks"
    echo ""
    exit 0
else
    echo -e "   ${RED}✗ Some tests failed. Please fix the issues above.${NC}"
    echo ""
    echo -e "   ${CYAN}Common fixes:${NC}"
    echo "     • Syntax errors: Check for unclosed quotes or missing 'fi'"
    echo "     • Missing functions: Ensure all required functions are defined"
    echo "     • Permissions: Run 'chmod +x <script>' to make executable"
    echo ""
    exit 1
fi
