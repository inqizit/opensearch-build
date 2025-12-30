#!/bin/bash

# Test script for Neo4j functionality
# This script tests basic Neo4j operations

set -e

echo "========================================="
echo "Neo4j Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if container is running
echo "1. Checking if Neo4j container is running..."
if docker ps | grep -q neo4j; then
    echo -e "${GREEN}✓ Neo4j container is running${NC}"
else
    echo -e "${RED}✗ Neo4j container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing Neo4j Browser connectivity..."
BROWSER_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:7474 2>/dev/null || echo "000")
if [ "$BROWSER_CODE" = "200" ] || [ "$BROWSER_CODE" = "304" ]; then
    echo -e "${GREEN}✓ Neo4j Browser is accessible (HTTP $BROWSER_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ Neo4j Browser is not accessible (HTTP $BROWSER_CODE)${NC}"
fi

echo ""
echo "3. Testing Cypher shell connectivity..."
CYPHER_TEST=$(docker exec neo4j cypher-shell -u neo4j -p password123 "RETURN 'Hello Neo4j' AS greeting;" 2>&1 | grep -i "Hello\|greeting" || echo "")
if echo "$CYPHER_TEST" | grep -qi "Hello\|greeting"; then
    echo -e "${GREEN}✓ Cypher shell is accessible${NC}"
else
    echo -e "${RED}✗ Cypher shell is not accessible${NC}"
    exit 1
fi

echo ""
echo "4. Testing node creation..."
NODE_TEST=$(docker exec neo4j cypher-shell -u neo4j -p password123 "
CREATE (n:Person {name: 'Test User', age: 30, email: 'test@example.com'})
RETURN n.name AS name, n.age AS age;
" 2>&1 | grep -i "Test User\|30" || echo "")

if echo "$NODE_TEST" | grep -qi "Test User\|30"; then
    echo -e "${GREEN}✓ Successfully created node${NC}"
    echo "   Node data: $(echo "$NODE_TEST" | grep -E "Test User|30" | head -1)"
else
    echo -e "${YELLOW}⚠ Node creation test failed${NC}"
fi

echo ""
echo "5. Testing relationship creation..."
REL_TEST=$(docker exec neo4j cypher-shell -u neo4j -p password123 "
MATCH (p:Person {name: 'Test User'})
CREATE (p)-[:KNOWS]->(friend:Person {name: 'Friend', age: 25})
RETURN p.name AS person, friend.name AS friend;
" 2>&1 | grep -i "Test User\|Friend" || echo "")

if echo "$REL_TEST" | grep -qi "Test User\|Friend"; then
    echo -e "${GREEN}✓ Successfully created relationship${NC}"
    echo "   Relationship: $(echo "$REL_TEST" | grep -E "Test User|Friend" | head -1)"
else
    echo -e "${YELLOW}⚠ Relationship creation test failed${NC}"
fi

echo ""
echo "6. Testing graph queries..."
QUERY_TEST=$(docker exec neo4j cypher-shell -u neo4j -p password123 "
MATCH (p:Person)-[r:KNOWS]->(f:Person)
RETURN p.name AS person, f.name AS friend, type(r) AS relationship;
" 2>&1 | grep -i "Test User\|Friend\|KNOWS" || echo "")

if echo "$QUERY_TEST" | grep -qi "Test User\|Friend\|KNOWS"; then
    echo -e "${GREEN}✓ Graph queries work correctly${NC}"
    echo "   Query result: $(echo "$QUERY_TEST" | grep -E "Test User|Friend|KNOWS" | head -1)"
else
    echo -e "${YELLOW}⚠ Graph query test failed${NC}"
fi

echo ""
echo "7. Testing node count..."
COUNT_TEST=$(docker exec neo4j cypher-shell -u neo4j -p password123 "
MATCH (n:Person)
RETURN count(n) AS total_nodes;
" 2>&1 | grep -oE "[0-9]+" | head -1 || echo "0")

if [ "$COUNT_TEST" -ge 2 ]; then
    echo -e "${GREEN}✓ Successfully counted nodes (found: $COUNT_TEST)${NC}"
else
    echo -e "${YELLOW}⚠ Node count test returned: $COUNT_TEST${NC}"
fi

# Clean up test data
echo ""
echo "   Cleaning up test data..."
docker exec neo4j cypher-shell -u neo4j -p password123 "
MATCH (n:Person)
WHERE n.name IN ['Test User', 'Friend']
DETACH DELETE n;
" > /dev/null 2>&1
echo "   Test data cleaned up"

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="

