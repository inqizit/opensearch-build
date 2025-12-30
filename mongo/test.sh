#!/bin/bash

# Test script for MongoDB functionality
# This script tests basic MongoDB operations

set -e

echo "========================================="
echo "MongoDB Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if container is running
echo "1. Checking if MongoDB container is running..."
if docker ps | grep -q mongodb; then
    echo -e "${GREEN}✓ MongoDB container is running${NC}"
else
    echo -e "${RED}✗ MongoDB container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing MongoDB connectivity..."
PING_RESULT=$(docker exec mongodb mongosh -u admin -p password123 --quiet --eval "db.adminCommand('ping')" 2>/dev/null || echo "")
if echo "$PING_RESULT" | grep -q "ok.*1"; then
    echo -e "${GREEN}✓ MongoDB is responding to ping${NC}"
else
    echo -e "${RED}✗ MongoDB is not responding correctly${NC}"
    exit 1
fi

echo ""
echo "3. Testing database creation..."
TEST_DB="testdb_$(date +%s)"
CREATE_RESULT=$(docker exec mongodb mongosh -u admin -p password123 --quiet --eval "use ${TEST_DB}; db.test.insertOne({test: 'value'}); db.getName()" 2>/dev/null || echo "")
if echo "$CREATE_RESULT" | grep -q "${TEST_DB}"; then
    echo -e "${GREEN}✓ Successfully created and used database: ${TEST_DB}${NC}"
    
    # Clean up - drop the test database
    docker exec mongodb mongosh -u admin -p password123 --quiet --eval "use ${TEST_DB}; db.dropDatabase()" > /dev/null 2>&1
    echo "   Test database cleaned up"
else
    echo -e "${YELLOW}⚠ Database creation test failed${NC}"
fi

echo ""
echo "4. Testing collection operations..."
COLLECTION_NAME="test_collection_$(date +%s)"
INSERT_RESULT=$(docker exec mongodb mongosh -u admin -p password123 --quiet --eval "use testdb; db.${COLLECTION_NAME}.insertOne({name: 'test', value: 123, timestamp: new Date()})" 2>/dev/null || echo "")
if echo "$INSERT_RESULT" | grep -q "acknowledged.*true"; then
    echo -e "${GREEN}✓ Successfully inserted document into collection${NC}"
    
    # Count documents
    COUNT_RESULT=$(docker exec mongodb mongosh -u admin -p password123 --quiet --eval "use testdb; db.${COLLECTION_NAME}.countDocuments()" 2>/dev/null || echo "")
    if echo "$COUNT_RESULT" | grep -q "1"; then
        echo -e "${GREEN}✓ Successfully counted documents (found: 1)${NC}"
    fi
    
    # Find documents
    FIND_RESULT=$(docker exec mongodb mongosh -u admin -p password123 --quiet --eval "use testdb; db.${COLLECTION_NAME}.findOne({name: 'test'})" 2>/dev/null || echo "")
    if echo "$FIND_RESULT" | grep -q "test"; then
        echo -e "${GREEN}✓ Successfully found document${NC}"
    fi
    
    # Clean up - drop the collection
    docker exec mongodb mongosh -u admin -p password123 --quiet --eval "use testdb; db.${COLLECTION_NAME}.drop()" > /dev/null 2>&1
    echo "   Test collection cleaned up"
else
    echo -e "${YELLOW}⚠ Collection operations test failed${NC}"
fi

echo ""
echo "5. Testing Mongo Express UI connectivity..."
UI_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8082 2>/dev/null || echo "000")
if [ "$UI_CODE" = "200" ] || [ "$UI_CODE" = "401" ]; then
    echo -e "${GREEN}✓ Mongo Express UI is accessible (HTTP $UI_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ Mongo Express UI is not accessible (HTTP $UI_CODE)${NC}"
fi

echo ""
echo "6. Testing list databases..."
LIST_DB=$(docker exec mongodb mongosh -u admin -p password123 --quiet --eval "db.adminCommand('listDatabases')" 2>/dev/null || echo "")
if echo "$LIST_DB" | grep -q "databases"; then
    echo -e "${GREEN}✓ Successfully listed databases${NC}"
else
    echo -e "${YELLOW}⚠ List databases test failed${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="

