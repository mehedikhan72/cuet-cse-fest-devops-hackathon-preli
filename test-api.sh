#!/bin/bash
# Test script for verifying the microservices setup
# Usage: ./test-api.sh

echo "===================================="
echo "E-Commerce Microservices API Tests"
echo "===================================="
echo ""

BASE_URL="http://localhost:5921"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

test_endpoint() {
    local name="$1"
    local url="$2"
    local method="${3:-GET}"
    local data="$4"
    
    echo -e "${YELLOW}Testing: $name${NC}"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "  ${GREEN}✓ PASSED - Status: $http_code${NC}"
        ((TESTS_PASSED++))
        echo "$body"
    else
        echo -e "  ${RED}✗ FAILED - Status: $http_code${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

test_should_fail() {
    local name="$1"
    local url="$2"
    
    echo -e "${YELLOW}Testing: $name (should fail)${NC}"
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "  ${RED}✗ FAILED - Should not be accessible!${NC}"
        ((TESTS_FAILED++))
    else
        echo -e "  ${GREEN}✓ PASSED - Correctly blocked${NC}"
        ((TESTS_PASSED++))
    fi
}

echo "Waiting for services to be ready..."
sleep 5

# Test 1: Gateway Health
echo ""
echo -e "${CYAN}1. Gateway Health Check${NC}"
test_endpoint "Gateway /health" "$BASE_URL/health"

# Test 2: Backend Health via Gateway
echo ""
echo -e "${CYAN}2. Backend Health Check (via Gateway)${NC}"
test_endpoint "Backend /api/health" "$BASE_URL/api/health"

# Test 3: Create Product
echo ""
echo -e "${CYAN}3. Create Product${NC}"
test_endpoint "POST /api/products" "$BASE_URL/api/products" "POST" \
    '{"name":"Test Product 1","price":99.99}'

# Test 4: Create Another Product
echo ""
echo -e "${CYAN}4. Create Another Product${NC}"
test_endpoint "POST /api/products" "$BASE_URL/api/products" "POST" \
    '{"name":"Test Product 2","price":149.99}'

# Test 5: Get All Products
echo ""
echo -e "${CYAN}5. Get All Products${NC}"
products=$(test_endpoint "GET /api/products" "$BASE_URL/api/products")
echo "$products" | jq '.' 2>/dev/null || echo "$products"

# Test 6: Input Validation - Invalid Name
echo ""
echo -e "${CYAN}6. Input Validation Tests${NC}"
echo -e "${YELLOW}Testing invalid inputs (should fail):${NC}"

http_code=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/products" \
    -H "Content-Type: application/json" \
    -d '{"name":"","price":50}' \
    -o /dev/null)

if [ "$http_code" -ge 400 ]; then
    echo -e "  ${GREEN}✓ PASSED - Correctly rejected empty name${NC}"
    ((TESTS_PASSED++))
else
    echo -e "  ${RED}✗ FAILED - Should reject empty name${NC}"
    ((TESTS_FAILED++))
fi

# Test 7: Input Validation - Invalid Price
http_code=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/products" \
    -H "Content-Type: application/json" \
    -d '{"name":"Product","price":-10}' \
    -o /dev/null)

if [ "$http_code" -ge 400 ]; then
    echo -e "  ${GREEN}✓ PASSED - Correctly rejected negative price${NC}"
    ((TESTS_PASSED++))
else
    echo -e "  ${RED}✗ FAILED - Should reject negative price${NC}"
    ((TESTS_FAILED++))
fi

# Test 8: Security - Direct Backend Access
echo ""
echo -e "${CYAN}7. Security Test - Direct Backend Access${NC}"
test_should_fail "Direct backend access" "http://localhost:3847/api/products"

# Test 9: Security - Direct MongoDB Access
echo ""
echo -e "${CYAN}8. Security Test - Direct MongoDB Access${NC}"
test_should_fail "Direct MongoDB access" "http://localhost:27017"

# Summary
echo ""
echo "===================================="
echo "Test Results Summary"
echo "===================================="
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
