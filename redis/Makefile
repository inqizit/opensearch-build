# Makefile for Redis - Self-Sufficient

.PHONY: help start stop restart logs status check clean test shell

# Default target
help:
	@echo "Redis Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start Redis (with Redis Commander UI)"
	@echo "  make stop       - Stop Redis"
	@echo "  make restart   - Restart Redis"
	@echo "  make logs       - View Redis logs (follow mode)"
	@echo "  make status     - Check Redis container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open Redis CLI"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  Redis:          localhost:6379"
	@echo "  Redis Commander: http://localhost:8081"

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

# Start Redis
start: check
	@echo "Starting Redis..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for Redis to be ready..."
	@sleep 5
	@echo "✓ Redis started"

# Stop Redis
stop:
	@echo "Stopping Redis..."
	@docker-compose -f docker-compose.yml down

# Restart Redis
restart: stop start

# View Redis logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check Redis container status
status:
	@echo "Redis Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=redis" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up Redis (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all Redis containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up Redis resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open Redis CLI
shell:
	@docker exec -it redis redis-cli

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing Redis connectivity..."; \
		if docker ps | grep -q redis; then \
			echo "✓ Redis container is running"; \
		else \
			echo "✗ Redis container is not running"; \
			exit 1; \
		fi; \
	fi

