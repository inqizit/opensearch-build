# Makefile for MongoDB - Self-Sufficient

.PHONY: help start stop restart logs status check clean test shell

# Default target
help:
	@echo "MongoDB Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start MongoDB (with Mongo Express UI)"
	@echo "  make stop       - Stop MongoDB"
	@echo "  make restart   - Restart MongoDB"
	@echo "  make logs       - View MongoDB logs (follow mode)"
	@echo "  make status     - Check MongoDB container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open MongoDB shell"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  MongoDB:        localhost:27017"
	@echo "  Mongo Express:  http://localhost:8082"
	@echo "  Default credentials:"
	@echo "    Username: admin"
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

# Start MongoDB
start: check
	@echo "Starting MongoDB..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for MongoDB to be ready..."
	@sleep 10
	@echo "✓ MongoDB started"

# Stop MongoDB
stop:
	@echo "Stopping MongoDB..."
	@docker-compose -f docker-compose.yml down

# Restart MongoDB
restart: stop start

# View MongoDB logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check MongoDB container status
status:
	@echo "MongoDB Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=mongodb" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up MongoDB (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all MongoDB containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up MongoDB resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open MongoDB shell
shell:
	@docker exec -it mongodb mongosh -u admin -p password123

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing MongoDB connectivity..."; \
		if docker ps | grep -q mongodb; then \
			echo "✓ MongoDB container is running"; \
		else \
			echo "✗ MongoDB container is not running"; \
			exit 1; \
		fi; \
	fi

