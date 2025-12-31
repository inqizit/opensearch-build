#!/bin/bash

# Test script for ClickHouse functionality
# This script tests basic ClickHouse operations

set -e

echo "========================================="
echo "ClickHouse Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if container is running
echo "1. Checking if ClickHouse container is running..."
if docker ps | grep -q clickhouse; then
    echo -e "${GREEN}✓ ClickHouse container is running${NC}"
else
    echo -e "${RED}✗ ClickHouse container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing ClickHouse HTTP API connectivity..."
PING_RESPONSE=$(curl -s http://127.0.0.1:8123/ping 2>/dev/null || echo "")
if [ "$PING_RESPONSE" = "Ok." ]; then
    echo -e "${GREEN}✓ ClickHouse HTTP API is accessible (ping: $PING_RESPONSE)${NC}"
else
    echo -e "${RED}✗ ClickHouse HTTP API is not accessible${NC}"
    exit 1
fi

echo ""
echo "3. Testing ClickHouse version..."
VERSION_TEST=$(curl -s http://127.0.0.1:8123/?query=SELECT%20version\(\) 2>/dev/null || echo "")
if [ -n "$VERSION_TEST" ]; then
    echo -e "${GREEN}✓ ClickHouse version query works${NC}"
    echo "   Version: $VERSION_TEST"
else
    echo -e "${YELLOW}⚠ Version query failed${NC}"
fi

echo ""
echo "4. Testing database operations..."
# Create a test database
DB_TEST=$(docker exec clickhouse clickhouse-client --query "
CREATE DATABASE IF NOT EXISTS test_db;
SHOW DATABASES;
" 2>&1 || echo "")

if echo "$DB_TEST" | grep -q "test_db"; then
    echo -e "${GREEN}✓ Successfully created database: test_db${NC}"
    
    # Clean up
    docker exec clickhouse clickhouse-client --query "DROP DATABASE IF EXISTS test_db;" > /dev/null 2>&1
    echo "   Test database cleaned up"
else
    echo -e "${YELLOW}⚠ Database creation test failed${NC}"
fi

echo ""
echo "5. Testing table creation and operations..."
TABLE_NAME="test_table_$(date +%s)"
CREATE_TABLE=$(docker exec clickhouse clickhouse-client --query "
CREATE TABLE ${TABLE_NAME} (
    id UInt32,
    name String,
    value Float64,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY id;

INSERT INTO ${TABLE_NAME} (id, name, value) VALUES
    (1, 'test', 123.45),
    (2, 'sample', 678.90);

SELECT * FROM ${TABLE_NAME};
" 2>&1 || echo "")

if echo "$CREATE_TABLE" | grep -q "test.*123.45"; then
    echo -e "${GREEN}✓ Successfully created table and inserted data${NC}"
    echo "   Sample data:"
    echo "$CREATE_TABLE" | grep -E "test|sample" | head -2 | sed 's/^/     /'
    
    # Count rows
    COUNT_RESULT=$(docker exec clickhouse clickhouse-client --query "SELECT COUNT(*) FROM ${TABLE_NAME};" 2>&1 || echo "0")
    if echo "$COUNT_RESULT" | grep -q "2"; then
        echo -e "${GREEN}✓ Successfully counted rows (found: 2)${NC}"
    fi
    
    # Clean up
    docker exec clickhouse clickhouse-client --query "DROP TABLE IF EXISTS ${TABLE_NAME};" > /dev/null 2>&1
    echo "   Test table cleaned up"
else
    echo -e "${YELLOW}⚠ Table operations test failed${NC}"
    # Clean up on failure
    docker exec clickhouse clickhouse-client --query "DROP TABLE IF EXISTS ${TABLE_NAME};" > /dev/null 2>&1
fi

echo ""
echo "6. Testing analytics/aggregation functions..."
ANALYTICS_TEST=$(docker exec clickhouse clickhouse-client --query "
CREATE TEMPORARY TABLE sales_temp (date Date, amount Float64) ENGINE = Memory;
INSERT INTO sales_temp VALUES
    ('2024-01-01', 100.0),
    ('2024-01-02', 150.0),
    ('2024-01-03', 200.0),
    ('2024-01-04', 175.0),
    ('2024-01-05', 225.0);

SELECT
    AVG(amount) as avg_amount,
    SUM(amount) as total_amount,
    MIN(amount) as min_amount,
    MAX(amount) as max_amount,
    COUNT(*) as count
FROM sales_temp;
" 2>&1 || echo "")

if echo "$ANALYTICS_TEST" | grep -q "170\|850"; then
    echo -e "${GREEN}✓ Analytics functions work correctly${NC}"
    echo "   Aggregation results:"
    echo "$ANALYTICS_TEST" | grep -E "[0-9]+\.[0-9]+" | head -1 | sed 's/^/     /'
else
    echo -e "${YELLOW}⚠ Analytics functions test failed${NC}"
fi

echo ""
echo "7. Testing Tabix UI connectivity..."
UI_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8084 2>/dev/null || echo "000")
if [ "$UI_CODE" = "200" ] || [ "$UI_CODE" = "302" ]; then
    echo -e "${GREEN}✓ Tabix UI is accessible (HTTP $UI_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ Tabix UI is not accessible (HTTP $UI_CODE)${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="


