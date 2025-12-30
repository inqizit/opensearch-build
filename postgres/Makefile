# Makefile for PostgreSQL - Self-Sufficient

.PHONY: help start stop restart logs status check clean test shell

# Default target
help:
	@echo "PostgreSQL Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start PostgreSQL (with pgAdmin UI)"
	@echo "  make stop       - Stop PostgreSQL"
	@echo "  make restart   - Restart PostgreSQL"
	@echo "  make logs       - View PostgreSQL logs (follow mode)"
	@echo "  make status     - Check PostgreSQL container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open PostgreSQL shell (psql)"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  PostgreSQL:     localhost:5432"
	@echo "  pgAdmin:        http://localhost:8083"
	@echo "  Default credentials:"
	@echo "    Username: admin"
	@echo "    Password: password123"
	@echo "    Database: testdb"
	@echo "  pgAdmin credentials:"
	@echo "    Email: admin@admin.com"
	@echo "    Password: admin"

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

# Start PostgreSQL
start: check
	@echo "Starting PostgreSQL..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for PostgreSQL to be ready..."
	@sleep 10
	@echo "✓ PostgreSQL started"

# Stop PostgreSQL
stop:
	@echo "Stopping PostgreSQL..."
	@docker-compose -f docker-compose.yml down

# Restart PostgreSQL
restart: stop start

# View PostgreSQL logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check PostgreSQL container status
status:
	@echo "PostgreSQL Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=postgres" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up PostgreSQL (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all PostgreSQL containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up PostgreSQL resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open PostgreSQL shell
shell:
	@docker exec -it postgres psql -U admin -d testdb

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing PostgreSQL connectivity..."; \
		if docker ps | grep -q postgres; then \
			echo "✓ PostgreSQL container is running"; \
		else \
			echo "✗ PostgreSQL container is not running"; \
			exit 1; \
		fi; \
	fi

