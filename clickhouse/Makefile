# Makefile for ClickHouse - Self-Sufficient

.PHONY: help start stop restart logs status check clean test shell

# Default target
help:
	@echo "ClickHouse Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start ClickHouse (with Tabix UI)"
	@echo "  make stop       - Stop ClickHouse"
	@echo "  make restart   - Restart ClickHouse"
	@echo "  make logs       - View ClickHouse logs (follow mode)"
	@echo "  make status     - Check ClickHouse container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open ClickHouse client"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  ClickHouse HTTP:  http://localhost:8123"
	@echo "  ClickHouse Native: localhost:9000"
	@echo "  Tabix UI:         http://localhost:8084"
	@echo "  Default credentials:"
	@echo "    Username: default"
	@echo "    Password: (empty)"

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

# Start ClickHouse
start: check
	@echo "Starting ClickHouse..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for ClickHouse to be ready..."
	@timeout=60; \
	while [ $$timeout -gt 0 ]; do \
		if curl -s http://127.0.0.1:8123/ping > /dev/null 2>&1; then \
			break; \
		fi; \
		sleep 2; \
		timeout=$$((timeout - 2)); \
		if [ $$((timeout % 10)) -eq 0 ]; then \
			echo "   Still waiting... ($$timeout seconds remaining)"; \
		fi; \
	done; \
	if [ $$timeout -gt 0 ]; then \
		echo "✓ ClickHouse started"; \
	else \
		echo "⚠ ClickHouse may still be starting (check with 'make status')"; \
	fi

# Stop ClickHouse
stop:
	@echo "Stopping ClickHouse..."
	@docker-compose -f docker-compose.yml down

# Restart ClickHouse
restart: stop start

# View ClickHouse logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check ClickHouse container status
status:
	@echo "ClickHouse Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=clickhouse" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up ClickHouse (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all ClickHouse containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up ClickHouse resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open ClickHouse client
shell:
	@docker exec -it clickhouse clickhouse-client

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing ClickHouse connectivity..."; \
		if docker ps | grep -q clickhouse; then \
			echo "✓ ClickHouse container is running"; \
		else \
			echo "✗ ClickHouse container is not running"; \
			exit 1; \
		fi; \
	fi


