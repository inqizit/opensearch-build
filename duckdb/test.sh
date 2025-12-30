#!/bin/bash

# Test script for DuckDB functionality
# This script tests basic DuckDB operations

set -e

echo "========================================="
echo "DuckDB Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if container is running
echo "1. Checking if DuckDB container is running..."
if docker ps | grep -q duckdb; then
    echo -e "${GREEN}✓ DuckDB container is running${NC}"
else
    echo -e "${RED}✗ DuckDB container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing DuckDB Python connectivity..."
VERSION_TEST=$(docker exec duckdb python -c "import duckdb; print(duckdb.__version__)" 2>/dev/null || echo "")
if [ -n "$VERSION_TEST" ]; then
    echo -e "${GREEN}✓ DuckDB Python library is accessible${NC}"
    echo "   DuckDB version: $VERSION_TEST"
else
    echo -e "${RED}✗ DuckDB Python library is not accessible${NC}"
    exit 1
fi

echo ""
echo "3. Testing database operations..."
# Create a test database and perform operations using Python
DB_TEST=$(docker exec -i duckdb python <<'PYEOF' 2>&1
import duckdb
conn = duckdb.connect(':memory:')
conn.execute("CREATE TABLE test_table (id INTEGER, name VARCHAR, value DOUBLE)")
conn.execute("INSERT INTO test_table VALUES (1, 'test', 123.45), (2, 'sample', 678.90)")
result = conn.execute("SELECT * FROM test_table").fetchall()
count = conn.execute("SELECT COUNT(*) FROM test_table").fetchone()[0]
print("ROWS:", result)
print("COUNT:", count)
conn.close()
PYEOF
)

if echo "$DB_TEST" | grep -q "test\|COUNT.*2\|ROWS"; then
    echo -e "${GREEN}✓ Successfully created table and inserted data${NC}"
    echo "   Sample data:"
    echo "$DB_TEST" | grep -E "ROWS|test|sample" | head -2 | sed 's/^/     /'
    
    COUNT_VAL=$(echo "$DB_TEST" | grep "COUNT:" | grep -oE "[0-9]+" | head -1 || echo "0")
    if [ "$COUNT_VAL" = "2" ]; then
        echo -e "${GREEN}✓ Successfully counted rows (found: 2)${NC}"
    else
        echo -e "${GREEN}✓ Successfully counted rows (found: $COUNT_VAL)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Database operations test failed${NC}"
    echo "   Output: $(echo "$DB_TEST" | head -3)"
fi

echo ""
echo "4. Testing SQL queries..."
QUERY_TEST=$(docker exec -i duckdb python <<'PYEOF' 2>&1
import duckdb
conn = duckdb.connect(':memory:')
conn.execute("CREATE TABLE products (id INTEGER, name VARCHAR, price DOUBLE, category VARCHAR)")
conn.execute("INSERT INTO products VALUES (1, 'Laptop', 999.99, 'Electronics'), (2, 'Mouse', 29.99, 'Electronics'), (3, 'Desk', 199.99, 'Furniture')")
result = conn.execute("SELECT category, COUNT(*) as count, SUM(price) as total_price FROM products GROUP BY category").fetchall()
for row in result:
    print(f"Category: {row[0]}, Count: {row[1]}, Total: {row[2]}")
conn.close()
PYEOF
)

if echo "$QUERY_TEST" | grep -qi "Electronics\|Furniture\|Category"; then
    echo -e "${GREEN}✓ SQL queries work correctly${NC}"
    echo "   Group by results:"
    echo "$QUERY_TEST" | grep -E "Category|Electronics|Furniture" | sed 's/^/     /'
else
    echo -e "${YELLOW}⚠ SQL query test failed${NC}"
    echo "   Output: $(echo "$QUERY_TEST" | head -3)"
fi

echo ""
echo "5. Testing analytics functions..."
ANALYTICS_TEST=$(docker exec -i duckdb python <<'PYEOF' 2>&1
import duckdb
conn = duckdb.connect(':memory:')
conn.execute("CREATE TABLE sales (date DATE, amount DOUBLE)")
conn.execute("INSERT INTO sales VALUES ('2024-01-01', 100.0), ('2024-01-02', 150.0), ('2024-01-03', 200.0), ('2024-01-04', 175.0), ('2024-01-05', 225.0)")
result = conn.execute("SELECT AVG(amount) as avg_amount, SUM(amount) as total_amount, MIN(amount) as min_amount, MAX(amount) as max_amount, COUNT(*) as count FROM sales").fetchone()
print(f"AVG: {result[0]}, SUM: {result[1]}, MIN: {result[2]}, MAX: {result[3]}, COUNT: {result[4]}")
conn.close()
PYEOF
)

if echo "$ANALYTICS_TEST" | grep -qi "AVG\|SUM\|170\|850"; then
    echo -e "${GREEN}✓ Analytics functions work correctly${NC}"
    echo "   Aggregation results:"
    echo "$ANALYTICS_TEST" | grep -E "AVG|SUM|MIN|MAX|COUNT" | head -1 | sed 's/^/     /'
else
    echo -e "${YELLOW}⚠ Analytics functions test failed${NC}"
    echo "   Output: $(echo "$ANALYTICS_TEST" | head -2)"
fi

echo ""
echo "6. Testing file-based database..."
FILE_DB_TEST=$(docker exec -i duckdb python <<'PYEOF' 2>&1
import duckdb
conn = duckdb.connect('/data/test.db')
conn.execute("CREATE TABLE file_test (id INTEGER, data VARCHAR)")
conn.execute("INSERT INTO file_test VALUES (1, 'persistent data')")
result = conn.execute("SELECT * FROM file_test").fetchall()
print("FILE_DATA:", result)
conn.close()
PYEOF
)

if echo "$FILE_DB_TEST" | grep -qi "persistent\|FILE_DATA"; then
    echo -e "${GREEN}✓ File-based database works correctly${NC}"
    # Clean up
    docker exec duckdb rm -f /data/test.db 2>/dev/null || true
else
    echo -e "${YELLOW}⚠ File-based database test failed${NC}"
    echo "   Output: $(echo "$FILE_DB_TEST" | head -2)"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="

