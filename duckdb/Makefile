# Makefile for DuckDB - Self-Sufficient

.PHONY: help start stop restart logs status check clean test shell

# Default target
help:
	@echo "DuckDB Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start DuckDB HTTP server"
	@echo "  make stop       - Stop DuckDB"
	@echo "  make restart   - Restart DuckDB"
	@echo "  make logs       - View DuckDB logs (follow mode)"
	@echo "  make status     - Check DuckDB container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open DuckDB CLI shell"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  DuckDB CLI: Available via 'make shell'"
	@echo "  Note: DuckDB is primarily an embedded database"
	@echo "        Install locally:"
	@echo "          Python: pip install duckdb"
	@echo "          Node.js: npm install duckdb"
	@echo "          Or use the container: docker exec -it duckdb duckdb"

# Check Docker connectivity
check:
	@echo "Checking Docker connectivity..."
	@if docker ps &> /dev/null; then \
		echo "✓ Docker daemon is accessible!"; \
	else \
		echo "✗ Cannot connect to Docker daemon"; \
		echo "  Make sure Docker/Rancher Desktop is running and WSL integration is enabled"; \
		exit 1; \
	fi

# Start DuckDB
start: check
	@echo "Starting DuckDB HTTP server..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for DuckDB to be ready..."
	@sleep 5
	@echo "✓ DuckDB started"

# Stop DuckDB
stop:
	@echo "Stopping DuckDB..."
	@docker-compose -f docker-compose.yml down

# Restart DuckDB
restart: stop start

# View DuckDB logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check DuckDB container status
status:
	@echo "DuckDB Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=duckdb" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up DuckDB (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all DuckDB containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up DuckDB resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open DuckDB CLI shell (using Python)
shell:
	@docker exec -it duckdb python -c "import duckdb; import code; db = duckdb.connect(':memory:'); code.interact(local=locals())"

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing DuckDB connectivity..."; \
		if docker ps | grep -q duckdb; then \
			echo "✓ DuckDB container is running"; \
		else \
			echo "✗ DuckDB container is not running"; \
			exit 1; \
		fi; \
	fi

