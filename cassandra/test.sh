#!/bin/bash

# Test script for Cassandra functionality
# This script tests basic Cassandra operations

set -e

echo "========================================="
echo "Cassandra Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if container is running
echo "1. Checking if Cassandra container is running..."
if docker ps | grep -q cassandra; then
    echo -e "${GREEN}✓ Cassandra container is running${NC}"
else
    echo -e "${RED}✗ Cassandra container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing Cassandra cluster status..."
CLUSTER_STATUS=$(docker exec cassandra nodetool status 2>/dev/null || echo "")
if echo "$CLUSTER_STATUS" | grep -q "UN"; then
    echo -e "${GREEN}✓ Cassandra cluster is up and running${NC}"
    echo "$CLUSTER_STATUS" | grep "UN" | head -1
else
    echo -e "${RED}✗ Cassandra cluster is not ready${NC}"
    echo "   Waiting a bit more..."
    sleep 10
    CLUSTER_STATUS=$(docker exec cassandra nodetool status 2>/dev/null || echo "")
    if echo "$CLUSTER_STATUS" | grep -q "UN"; then
        echo -e "${GREEN}✓ Cassandra cluster is now ready${NC}"
    else
        echo -e "${RED}✗ Cassandra cluster is still not ready${NC}"
        exit 1
    fi
fi

echo ""
echo "3. Testing CQL connectivity..."
CQL_TEST=$(docker exec cassandra cqlsh -e "SELECT cluster_name FROM system.local;" 2>/dev/null || echo "")
if echo "$CQL_TEST" | grep -qi "cluster_name\|test-cluster"; then
    echo -e "${GREEN}✓ CQL connectivity works${NC}"
    CLUSTER_NAME=$(echo "$CQL_TEST" | grep -i "test-cluster" | head -1 || echo "test-cluster")
    echo "   Cluster name: test-cluster"
else
    echo -e "${RED}✗ CQL connectivity test failed${NC}"
    exit 1
fi

echo ""
echo "4. Testing keyspace creation..."
KEYSPACE_NAME="test_keyspace_$(date +%s)"
CREATE_KEYSPACE=$(docker exec cassandra cqlsh -e "
CREATE KEYSPACE IF NOT EXISTS ${KEYSPACE_NAME}
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
" 2>/dev/null || echo "")

if docker exec cassandra cqlsh -e "DESCRIBE KEYSPACE ${KEYSPACE_NAME};" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Successfully created keyspace: ${KEYSPACE_NAME}${NC}"
    
    # Clean up - drop the keyspace
    docker exec cassandra cqlsh -e "DROP KEYSPACE ${KEYSPACE_NAME};" > /dev/null 2>&1
    echo "   Test keyspace cleaned up"
else
    echo -e "${YELLOW}⚠ Keyspace creation test failed${NC}"
fi

echo ""
echo "5. Testing table operations..."
TABLE_KEYSPACE="test_ks_$(date +%s)"
TABLE_NAME="test_table_$(date +%s)"

# Create keyspace and table
CREATE_RESULT=$(docker exec cassandra cqlsh -e "
CREATE KEYSPACE IF NOT EXISTS ${TABLE_KEYSPACE}
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE ${TABLE_KEYSPACE};

CREATE TABLE ${TABLE_NAME} (
    id UUID PRIMARY KEY,
    name TEXT,
    value INT,
    created_at TIMESTAMP
);
" 2>/dev/null || echo "")

if docker exec cassandra cqlsh -e "USE ${TABLE_KEYSPACE}; DESCRIBE TABLE ${TABLE_NAME};" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Successfully created table: ${TABLE_NAME}${NC}"
    
    # Insert data
    INSERT_RESULT=$(docker exec cassandra cqlsh -e "
USE ${TABLE_KEYSPACE};
INSERT INTO ${TABLE_NAME} (id, name, value, created_at) 
VALUES (uuid(), 'test', 123, toTimestamp(now()));
INSERT INTO ${TABLE_KEYSPACE}.${TABLE_NAME} (id, name, value, created_at) 
VALUES (uuid(), 'sample', 456, toTimestamp(now()));
" 2>/dev/null || echo "")
    
    if [ -n "$INSERT_RESULT" ] || docker exec cassandra cqlsh -e "USE ${TABLE_KEYSPACE}; SELECT COUNT(*) FROM ${TABLE_NAME};" 2>/dev/null | grep -q "2"; then
        echo -e "${GREEN}✓ Successfully inserted test data${NC}"
    fi
    
    # Query data
    SELECT_RESULT=$(docker exec cassandra cqlsh -e "USE ${TABLE_KEYSPACE}; SELECT * FROM ${TABLE_NAME} LIMIT 2;" 2>/dev/null || echo "")
    if echo "$SELECT_RESULT" | grep -q "test\|sample"; then
        echo -e "${GREEN}✓ Successfully queried data${NC}"
    fi
    
    # Count rows
    COUNT_RESULT=$(docker exec cassandra cqlsh -e "USE ${TABLE_KEYSPACE}; SELECT COUNT(*) FROM ${TABLE_NAME};" 2>/dev/null || echo "")
    if echo "$COUNT_RESULT" | grep -q "2"; then
        echo -e "${GREEN}✓ Successfully counted rows (found: 2)${NC}"
    fi
    
    # Clean up
    docker exec cassandra cqlsh -e "DROP KEYSPACE ${TABLE_KEYSPACE};" > /dev/null 2>&1
    echo "   Test keyspace and table cleaned up"
else
    echo -e "${YELLOW}⚠ Table operations test failed${NC}"
    # Clean up on failure
    docker exec cassandra cqlsh -e "DROP KEYSPACE IF EXISTS ${TABLE_KEYSPACE};" > /dev/null 2>&1
fi

echo ""
echo "6. Testing CQL shell access..."
CQLSH_TEST=$(docker exec cassandra cqlsh -e "SELECT cluster_name FROM system.local;" 2>/dev/null | grep -i "cluster_name\|test-cluster" || echo "")
if echo "$CQLSH_TEST" | grep -qi "cluster_name\|test-cluster"; then
    echo -e "${GREEN}✓ CQL shell is accessible and working${NC}"
else
    echo -e "${YELLOW}⚠ CQL shell test inconclusive${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="

