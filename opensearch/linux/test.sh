#!/bin/bash

# Test script for OpenSearch functionality
# This script tests basic OpenSearch operations

set -e

echo "========================================="
echo "OpenSearch Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if containers are running
echo "1. Checking if OpenSearch containers are running..."
if docker ps | grep -q opensearch-node1; then
    echo -e "${GREEN}✓ OpenSearch containers are running${NC}"
else
    echo -e "${RED}✗ OpenSearch containers are not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

# Get password from .env file
if [ -f .env ]; then
    PASSWORD=$(grep OPENSEARCH_INITIAL_ADMIN_PASSWORD .env | cut -d'=' -f2)
else
    PASSWORD="MySecure123!"
fi

echo ""
echo "2. Testing OpenSearch API connectivity..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u admin:${PASSWORD} http://127.0.0.1:9200 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ OpenSearch API is accessible (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ OpenSearch API is not accessible (HTTP $HTTP_CODE)${NC}"
    exit 1
fi

echo ""
echo "3. Testing cluster health..."
HEALTH=$(curl -s -u admin:${PASSWORD} http://127.0.0.1:9200/_cluster/health 2>/dev/null || echo "")
if [ -n "$HEALTH" ]; then
    STATUS=$(echo $HEALTH | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✓ Cluster health check successful${NC}"
    echo "   Cluster status: $STATUS"
else
    echo -e "${RED}✗ Failed to get cluster health${NC}"
    exit 1
fi

echo ""
echo "4. Testing index creation..."
INDEX_NAME="test-index-$(date +%s)"
CREATE_RESPONSE=$(curl -s -X PUT -u admin:${PASSWORD} "http://127.0.0.1:9200/${INDEX_NAME}" 2>/dev/null || echo "")
if echo "$CREATE_RESPONSE" | grep -q "acknowledged"; then
    echo -e "${GREEN}✓ Successfully created test index: ${INDEX_NAME}${NC}"
    
    # Clean up - delete the test index
    curl -s -X DELETE -u admin:${PASSWORD} "http://127.0.0.1:9200/${INDEX_NAME}" > /dev/null 2>&1
    echo "   Test index cleaned up"
else
    echo -e "${YELLOW}⚠ Index creation test failed or returned unexpected response${NC}"
fi

echo ""
echo "5. Testing OpenSearch Dashboards connectivity..."
DASHBOARDS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5601 2>/dev/null || echo "000")
if [ "$DASHBOARDS_CODE" = "302" ] || [ "$DASHBOARDS_CODE" = "200" ]; then
    echo -e "${GREEN}✓ OpenSearch Dashboards is accessible (HTTP $DASHBOARDS_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ OpenSearch Dashboards is not accessible (HTTP $DASHBOARDS_CODE)${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="

