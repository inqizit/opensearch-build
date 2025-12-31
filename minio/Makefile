# Makefile for MinIO (S3-compatible) - Self-Sufficient

.PHONY: help start stop restart logs status check clean test

# Default target
help:
	@echo "MinIO (S3-compatible) Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start MinIO"
	@echo "  make stop       - Stop MinIO"
	@echo "  make restart    - Restart MinIO"
	@echo "  make logs       - View MinIO logs (follow mode)"
	@echo "  make status     - Check MinIO container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  MinIO API:      http://localhost:9000"
	@echo "  MinIO Console:  http://localhost:9001"
	@echo "  Default Credentials: minioadmin / minioadmin"

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

# Start MinIO
start: check
	@echo "Starting MinIO..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for MinIO to be ready..."
	@sleep 5
	@echo "✓ MinIO started"
	@echo "  API: http://localhost:9000"
	@echo "  Console: http://localhost:9001"

# Stop MinIO
stop:
	@echo "Stopping MinIO..."
	@docker-compose -f docker-compose.yml down

# Restart MinIO
restart: stop start

# View MinIO logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check MinIO container status
status:
	@echo "MinIO Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=minio" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up MinIO (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all MinIO containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up MinIO resources"; \
	else \
		echo "Cancelled."; \
	fi

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing MinIO connectivity..."; \
		if docker ps | grep -q minio; then \
			echo "✓ MinIO container is running"; \
		else \
			echo "✗ MinIO container is not running"; \
			exit 1; \
		fi; \
	fi

