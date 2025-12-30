# Makefile for Cassandra - Self-Sufficient

.PHONY: help start stop restart logs status check clean test shell

# Default target
help:
	@echo "Cassandra Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start Cassandra (with Cassandra Web UI)"
	@echo "  make stop       - Stop Cassandra"
	@echo "  make restart   - Restart Cassandra"
	@echo "  make logs       - View Cassandra logs (follow mode)"
	@echo "  make status     - Check Cassandra container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open Cassandra CQL shell (cqlsh)"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  Cassandra:      localhost:9042"
	@echo "  CQL Shell:      Use 'make shell' to access cqlsh"

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

# Start Cassandra
start: check
	@echo "Starting Cassandra..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for Cassandra to be ready (this may take 60+ seconds)..."
	@timeout=120; \
	while [ $$timeout -gt 0 ]; do \
		if docker exec cassandra nodetool status 2>/dev/null | grep -q "UN"; then \
			break; \
		fi; \
		sleep 5; \
		timeout=$$((timeout - 5)); \
		if [ $$((timeout % 30)) -eq 0 ]; then \
			echo "   Still waiting... ($$timeout seconds remaining)"; \
		fi; \
	done; \
	if [ $$timeout -gt 0 ]; then \
		echo "✓ Cassandra started"; \
	else \
		echo "⚠ Cassandra may still be starting (check with 'make status')"; \
	fi

# Stop Cassandra
stop:
	@echo "Stopping Cassandra..."
	@docker-compose -f docker-compose.yml down

# Restart Cassandra
restart: stop start

# View Cassandra logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check Cassandra container status
status:
	@echo "Cassandra Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=cassandra" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "Cluster Status:"
	@docker exec cassandra nodetool status 2>/dev/null || echo "Cassandra not ready yet"

# Clean up Cassandra (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all Cassandra containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up Cassandra resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open Cassandra CQL shell
shell:
	@docker exec -it cassandra cqlsh

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing Cassandra connectivity..."; \
		if docker ps | grep -q cassandra; then \
			echo "✓ Cassandra container is running"; \
		else \
			echo "✗ Cassandra container is not running"; \
			exit 1; \
		fi; \
	fi

