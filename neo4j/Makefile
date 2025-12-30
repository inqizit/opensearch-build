# Makefile for Neo4j - Self-Sufficient

.PHONY: help start stop restart logs status check clean test shell

# Default target
help:
	@echo "Neo4j Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start Neo4j"
	@echo "  make stop       - Stop Neo4j"
	@echo "  make restart   - Restart Neo4j"
	@echo "  make logs       - View Neo4j logs (follow mode)"
	@echo "  make status     - Check Neo4j container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open Neo4j Cypher shell"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  Neo4j Browser:   http://localhost:7474"
	@echo "  Neo4j Bolt:      localhost:7687"
	@echo "  Default credentials:"
	@echo "    Username: neo4j"
	@echo "    Password: password123"

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

# Start Neo4j
start: check
	@echo "Starting Neo4j..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for Neo4j to be ready..."
	@timeout=60; \
	while [ $$timeout -gt 0 ]; do \
		if curl -s http://127.0.0.1:7474 > /dev/null 2>&1; then \
			break; \
		fi; \
		sleep 2; \
		timeout=$$((timeout - 2)); \
		if [ $$((timeout % 10)) -eq 0 ]; then \
			echo "   Still waiting... ($$timeout seconds remaining)"; \
		fi; \
	done; \
	if [ $$timeout -gt 0 ]; then \
		echo "✓ Neo4j started"; \
	else \
		echo "⚠ Neo4j may still be starting (check with 'make status')"; \
	fi

# Stop Neo4j
stop:
	@echo "Stopping Neo4j..."
	@docker-compose -f docker-compose.yml down

# Restart Neo4j
restart: stop start

# View Neo4j logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check Neo4j container status
status:
	@echo "Neo4j Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=neo4j" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up Neo4j (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all Neo4j containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up Neo4j resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open Neo4j Cypher shell
shell:
	@docker exec -it neo4j cypher-shell -u neo4j -p password123

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing Neo4j connectivity..."; \
		if docker ps | grep -q neo4j; then \
			echo "✓ Neo4j container is running"; \
		else \
			echo "✗ Neo4j container is not running"; \
			exit 1; \
		fi; \
	fi

