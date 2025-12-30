#!/bin/bash

# Test script for Redis functionality
# This script tests basic Redis operations

set -e

echo "========================================="
echo "Redis Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if container is running
echo "1. Checking if Redis container is running..."
if docker ps | grep -q redis; then
    echo -e "${GREEN}✓ Redis container is running${NC}"
else
    echo -e "${RED}✗ Redis container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing Redis PING command..."
PING_RESULT=$(docker exec redis redis-cli PING 2>/dev/null || echo "")
if [ "$PING_RESULT" = "PONG" ]; then
    echo -e "${GREEN}✓ Redis is responding to PING (got: $PING_RESULT)${NC}"
else
    echo -e "${RED}✗ Redis is not responding correctly (got: $PING_RESULT)${NC}"
    exit 1
fi

echo ""
echo "3. Testing SET and GET operations..."
TEST_KEY="test-key-$(date +%s)"
TEST_VALUE="test-value-$(date +%s)"

# Set a value
SET_RESULT=$(docker exec redis redis-cli SET ${TEST_KEY} "${TEST_VALUE}" 2>/dev/null || echo "")
if [ "$SET_RESULT" = "OK" ]; then
    echo -e "${GREEN}✓ Successfully SET key: ${TEST_KEY}${NC}"
    
    # Get the value
    GET_RESULT=$(docker exec redis redis-cli GET ${TEST_KEY} 2>/dev/null || echo "")
    if [ "$GET_RESULT" = "$TEST_VALUE" ]; then
        echo -e "${GREEN}✓ Successfully GET key: ${TEST_KEY} = ${GET_RESULT}${NC}"
    else
        echo -e "${RED}✗ GET returned unexpected value: ${GET_RESULT}${NC}"
    fi
    
    # Clean up - delete the test key
    docker exec redis redis-cli DEL ${TEST_KEY} > /dev/null 2>&1
    echo "   Test key cleaned up"
else
    echo -e "${RED}✗ SET operation failed${NC}"
    exit 1
fi

echo ""
echo "4. Testing INCR operation..."
INCR_KEY="test-counter-$(date +%s)"
INCR_RESULT1=$(docker exec redis redis-cli INCR ${INCR_KEY} 2>/dev/null || echo "")
INCR_RESULT2=$(docker exec redis redis-cli INCR ${INCR_KEY} 2>/dev/null || echo "")
if [ "$INCR_RESULT1" = "1" ] && [ "$INCR_RESULT2" = "2" ]; then
    echo -e "${GREEN}✓ INCR operation works correctly (1, 2)${NC}"
    # Clean up
    docker exec redis redis-cli DEL ${INCR_KEY} > /dev/null 2>&1
else
    echo -e "${YELLOW}⚠ INCR operation test failed${NC}"
fi

echo ""
echo "5. Testing Redis Commander UI connectivity..."
UI_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8081 2>/dev/null || echo "000")
if [ "$UI_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Redis Commander UI is accessible (HTTP $UI_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ Redis Commander UI is not accessible (HTTP $UI_CODE)${NC}"
fi

echo ""
echo "6. Testing INFO command..."
INFO_RESULT=$(docker exec redis redis-cli INFO server 2>/dev/null | grep -q "redis_version" && echo "OK" || echo "")
if [ -n "$INFO_RESULT" ]; then
    echo -e "${GREEN}✓ INFO command works correctly${NC}"
else
    echo -e "${YELLOW}⚠ INFO command test failed${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="

