#!/bin/bash

# System Requirements Checker for Magento 2
# Run this before deploying to check if your server meets the requirements

echo "========================================"
echo "  Magento 2 System Requirements Check"
echo "========================================"
echo ""

ERRORS=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

echo "Operating System:"
OS=$(uname -s)
DISTRO=$(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")
echo "  $DISTRO ($OS)"
if [[ "$OS" == "Linux" ]]; then
    check_pass "Linux operating system detected"
else
    check_fail "Linux required, but detected: $OS"
fi
echo ""

echo "Memory:"
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
if [ "$TOTAL_MEM" -ge 8000 ]; then
    check_pass "Total RAM: ${TOTAL_MEM}MB (Recommended: 8GB+)"
elif [ "$TOTAL_MEM" -ge 4000 ]; then
    check_warn "Total RAM: ${TOTAL_MEM}MB (Minimum: 4GB, Recommended: 8GB)"
else
    check_fail "Total RAM: ${TOTAL_MEM}MB (Minimum 4GB required)"
fi
echo ""

echo "Disk Space:"
AVAILABLE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -ge 20 ]; then
    check_pass "Available disk space: ${AVAILABLE_SPACE}GB (Minimum: 20GB)"
else
    check_fail "Available disk space: ${AVAILABLE_SPACE}GB (Minimum 20GB required)"
fi
echo ""

echo "Network:"
if ping -c 1 google.com &> /dev/null; then
    check_pass "Internet connection available"
else
    check_fail "No internet connection detected"
fi
echo ""

echo "Required Ports:"
for port in 80 443 3306 9200 6379; do
    if ! netstat -tuln 2>/dev/null | grep -q ":$port " && ! ss -tuln 2>/dev/null | grep -q ":$port "; then
        check_pass "Port $port is available"
    else
        check_warn "Port $port is already in use (may need to stop existing services)"
    fi
done
echo ""

echo "Software Requirements:"

# Check for curl
if command -v curl &> /dev/null; then
    check_pass "curl is installed"
else
    check_fail "curl is not installed (required for installation)"
fi

# Check for git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    check_pass "git is installed (version $GIT_VERSION)"
else
    check_warn "git is not installed (will be installed during setup)"
fi

# Check for docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    check_pass "Docker is installed (version $DOCKER_VERSION)"
else
    check_warn "Docker is not installed (will be installed during setup)"
fi

# Check for docker-compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | awk '{print $3}' | sed 's/,//')
    check_pass "Docker Compose is installed (version $COMPOSE_VERSION)"
else
    check_warn "Docker Compose is not installed (will be installed during setup)"
fi

echo ""
echo "========================================"
echo "  Summary"
echo "========================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC} Your system is ready for Magento 2 installation."
    echo ""
    echo "To proceed with installation, run:"
    echo "  bash <(curl -s https://raw.githubusercontent.com/theuargb/magento2-copilot-demo/copilot/install-magento-shop/quick-start.sh)"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}Warnings found: $WARNINGS${NC}"
    echo "Your system should work, but some issues may need attention."
    echo "You can proceed with installation at your own risk."
else
    echo -e "${RED}Errors found: $ERRORS${NC}"
    echo -e "${YELLOW}Warnings found: $WARNINGS${NC}"
    echo ""
    echo "Please fix the errors before proceeding with installation."
fi

echo ""
exit $ERRORS
