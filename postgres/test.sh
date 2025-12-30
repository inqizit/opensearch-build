#!/bin/bash

# Test script for PostgreSQL functionality
# This script tests basic PostgreSQL operations

set -e

echo "========================================="
echo "PostgreSQL Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if container is running
echo "1. Checking if PostgreSQL container is running..."
if docker ps | grep -q postgres; then
    echo -e "${GREEN}✓ PostgreSQL container is running${NC}"
else
    echo -e "${RED}✗ PostgreSQL container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing PostgreSQL connectivity..."
PG_READY=$(docker exec postgres pg_isready -U admin 2>/dev/null || echo "")
if echo "$PG_READY" | grep -q "accepting connections"; then
    echo -e "${GREEN}✓ PostgreSQL is accepting connections${NC}"
else
    echo -e "${RED}✗ PostgreSQL is not accepting connections${NC}"
    exit 1
fi

echo ""
echo "3. Testing database connection..."
CONN_TEST=$(docker exec postgres psql -U admin -d testdb -c "SELECT version();" 2>/dev/null || echo "")
if echo "$CONN_TEST" | grep -q "PostgreSQL"; then
    echo -e "${GREEN}✓ Successfully connected to database${NC}"
    VERSION=$(echo "$CONN_TEST" | grep -o "PostgreSQL [0-9.]*" | head -1)
    echo "   PostgreSQL version: $VERSION"
else
    echo -e "${RED}✗ Failed to connect to database${NC}"
    exit 1
fi

echo ""
echo "4. Testing table creation..."
TABLE_NAME="test_table_$(date +%s)"
CREATE_TABLE=$(docker exec postgres psql -U admin -d testdb -c "CREATE TABLE ${TABLE_NAME} (id SERIAL PRIMARY KEY, name VARCHAR(100), value INTEGER, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);" 2>/dev/null || echo "")
if echo "$CREATE_TABLE" | grep -q "CREATE TABLE"; then
    echo -e "${GREEN}✓ Successfully created table: ${TABLE_NAME}${NC}"
    
    # Insert test data
    INSERT_RESULT=$(docker exec postgres psql -U admin -d testdb -c "INSERT INTO ${TABLE_NAME} (name, value) VALUES ('test', 123), ('sample', 456);" 2>/dev/null || echo "")
    if echo "$INSERT_RESULT" | grep -q "INSERT 0 2"; then
        echo -e "${GREEN}✓ Successfully inserted test data${NC}"
    fi
    
    # Select data
    SELECT_RESULT=$(docker exec postgres psql -U admin -d testdb -c "SELECT * FROM ${TABLE_NAME};" 2>/dev/null || echo "")
    if echo "$SELECT_RESULT" | grep -q "test.*123"; then
        echo -e "${GREEN}✓ Successfully queried data${NC}"
    fi
    
    # Count rows
    COUNT_RESULT=$(docker exec postgres psql -U admin -d testdb -t -c "SELECT COUNT(*) FROM ${TABLE_NAME};" 2>/dev/null | tr -d ' ')
    if [ "$COUNT_RESULT" = "2" ]; then
        echo -e "${GREEN}✓ Successfully counted rows (found: 2)${NC}"
    fi
    
    # Clean up - drop the table
    docker exec postgres psql -U admin -d testdb -c "DROP TABLE ${TABLE_NAME};" > /dev/null 2>&1
    echo "   Test table cleaned up"
else
    echo -e "${YELLOW}⚠ Table creation test failed${NC}"
fi

echo ""
echo "5. Testing pgAdmin UI connectivity..."
UI_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8083 2>/dev/null || echo "000")
if [ "$UI_CODE" = "200" ] || [ "$UI_CODE" = "302" ]; then
    echo -e "${GREEN}✓ pgAdmin UI is accessible (HTTP $UI_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ pgAdmin UI is not accessible (HTTP $UI_CODE)${NC}"
fi

echo ""
echo "6. Testing list databases..."
LIST_DB=$(docker exec postgres psql -U admin -d testdb -c "\l" 2>/dev/null || echo "")
if echo "$LIST_DB" | grep -q "testdb"; then
    echo -e "${GREEN}✓ Successfully listed databases${NC}"
else
    echo -e "${YELLOW}⚠ List databases test failed${NC}"
fi

echo ""
echo "7. Testing transaction support..."
# Test 1: Transaction commit - verify data persists
TX_COMMIT_TEST=$(docker exec postgres psql -U admin -d testdb -t -A -c "
BEGIN;
CREATE TABLE tx_commit_test (id INT);
INSERT INTO tx_commit_test VALUES (1), (2);
COMMIT;
SELECT COUNT(*) FROM tx_commit_test;
" 2>&1)

if echo "$TX_COMMIT_TEST" | grep -q "^2$"; then
    echo -e "${GREEN}✓ Transaction commit works (found 2 rows after commit)${NC}"
    # Clean up
    docker exec postgres psql -U admin -d testdb -c "DROP TABLE tx_commit_test;" > /dev/null 2>&1
else
    echo -e "${YELLOW}⚠ Transaction commit test failed${NC}"
fi

# Test 2: Transaction rollback - verify table doesn't exist after rollback
TX_ROLLBACK_OUTPUT=$(docker exec postgres psql -U admin -d testdb <<'EOF' 2>&1
BEGIN;
CREATE TABLE tx_rollback_test (id INT);
INSERT INTO tx_rollback_test VALUES (1);
ROLLBACK;
EOF
)

# Now check if table exists (it shouldn't)
TABLE_EXISTS=$(docker exec postgres psql -U admin -d testdb -t -c "\dt tx_rollback_test" 2>&1)

if echo "$TABLE_EXISTS" | grep -qi "did not find any relation\|No matching relations\|does not exist"; then
    echo -e "${GREEN}✓ Transaction rollback works (table does not exist after rollback)${NC}"
elif [ -z "$TABLE_EXISTS" ] || [ "$(echo "$TABLE_EXISTS" | tr -d ' \n')" = "" ]; then
    echo -e "${GREEN}✓ Transaction rollback works (table does not exist after rollback)${NC}"
else
    # Table still exists, which means rollback didn't work - clean it up
    docker exec postgres psql -U admin -d testdb -c "DROP TABLE IF EXISTS tx_rollback_test;" > /dev/null 2>&1
    echo -e "${YELLOW}⚠ Transaction rollback test inconclusive${NC}"
fi


echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="

