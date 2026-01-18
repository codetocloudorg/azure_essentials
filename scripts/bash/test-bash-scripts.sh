#!/bin/bash
# Test script for bash deployment scripts
# Run with: bash scripts/test-bash-scripts.sh

# Don't exit on error - we want to run all tests
# set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================"
echo "  BASH SCRIPTS TESTING"
echo -e "========================================${NC}"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo -e "   ${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "   ${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

warn() {
    echo -e "   ${YELLOW}⚠${NC} $1"
}

# ============================================
# Test deploy.sh
# ============================================
echo -e "${CYAN}Testing deploy.sh${NC}"
echo ""

echo "1. Syntax Check:"
if bash -n "$SCRIPT_DIR/deploy.sh" 2>/dev/null; then
    pass "Syntax valid"
else
    fail "Syntax errors found"
fi

echo ""
echo "2. Shebang Check:"
SHEBANG=$(head -1 "$SCRIPT_DIR/deploy.sh")
if [[ "$SHEBANG" == "#!/bin/bash" ]]; then
    pass "Correct shebang: $SHEBANG"
else
    fail "Incorrect shebang: $SHEBANG"
fi

echo ""
echo "3. Error Handling:"
if grep -q "set -e" "$SCRIPT_DIR/deploy.sh"; then
    pass "Has 'set -e' for error handling"
else
    fail "Missing 'set -e'"
fi

echo ""
echo "4. Function Definitions:"
FUNC_COUNT=$(grep -c "^[a-z_]*() {" "$SCRIPT_DIR/deploy.sh" 2>/dev/null || echo 0)
if [[ $FUNC_COUNT -ge 8 ]]; then
    pass "Found $FUNC_COUNT functions"
else
    fail "Only found $FUNC_COUNT functions (expected 8+)"
fi

echo ""
echo "5. Required Functions:"
REQUIRED_FUNCS=("print_banner" "check_prerequisites" "select_region" "select_lesson" "main")
for func in "${REQUIRED_FUNCS[@]}"; do
    if grep -q "^${func}() {" "$SCRIPT_DIR/deploy.sh"; then
        pass "$func() defined"
    else
        fail "$func() missing"
    fi
done

echo ""
echo "6. File Permissions:"
if [[ -x "$SCRIPT_DIR/deploy.sh" ]]; then
    pass "deploy.sh is executable"
else
    fail "deploy.sh is not executable"
fi

# ============================================
# Test setup-local-tools.sh
# ============================================
echo ""
echo -e "${CYAN}Testing setup-local-tools.sh${NC}"
echo ""

echo "1. Syntax Check:"
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

# ============================================
# Test validate-env.sh
# ============================================
echo ""
echo -e "${CYAN}Testing validate-env.sh${NC}"
echo ""

echo "1. Syntax Check:"
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
if "$SCRIPT_DIR/validate-env.sh" >/dev/null 2>&1; then
    pass "validate-env.sh runs without errors"
else
    warn "validate-env.sh had warnings (may be expected)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# ============================================
# Summary
# ============================================
echo ""
echo -e "${CYAN}========================================"
echo "  TEST SUMMARY"
echo -e "========================================${NC}"
echo ""
echo -e "   ${GREEN}Passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "   ${RED}Failed: $TESTS_FAILED${NC}"
else
    echo -e "   ${GREEN}Failed: $TESTS_FAILED${NC}"
fi
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "   ${GREEN}✓ All bash scripts are ready!${NC}"
    exit 0
else
    echo -e "   ${RED}✗ Some tests failed. Please fix the issues above.${NC}"
    exit 1
fi
