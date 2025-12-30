# Makefile for Kafka - Self-Sufficient

.PHONY: help start stop restart logs status check clean test

# Default target
help:
	@echo "Kafka Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start Kafka cluster (Zookeeper + Kafka + Kafka UI)"
	@echo "  make stop       - Stop Kafka cluster"
	@echo "  make restart   - Restart Kafka cluster"
	@echo "  make logs       - View Kafka logs (follow mode)"
	@echo "  make status     - Check Kafka container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  Kafka Broker:   localhost:9092"
	@echo "  Zookeeper:      localhost:2181"
	@echo "  Kafka UI:       http://localhost:8080"

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

# Start Kafka cluster
start: check
	@echo "Starting Kafka cluster..."
	@docker-compose -f docker-compose.yml up -d
	@echo "Waiting for services to be ready..."
	@echo "  Waiting for Zookeeper..."
	@timeout=60; \
	while [ $$timeout -gt 0 ]; do \
		if docker exec zookeeper nc -z localhost 2181 >/dev/null 2>&1; then \
			break; \
		fi; \
		sleep 1; \
		timeout=$$((timeout - 1)); \
	done; \
	if [ $$timeout -eq 0 ]; then \
		echo "⚠ Zookeeper may still be starting..."; \
	else \
		echo "  ✓ Zookeeper is ready"; \
	fi
	@echo "  Waiting for Kafka broker..."
	@timeout=60; \
	while [ $$timeout -gt 0 ]; do \
		if docker exec kafka kafka-broker-api-versions --bootstrap-server kafka:9093 >/dev/null 2>&1 || \
		   docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 >/dev/null 2>&1; then \
			break; \
		fi; \
		sleep 2; \
		timeout=$$((timeout - 2)); \
	done; \
	if [ $$timeout -eq 0 ]; then \
		echo "⚠ Kafka may still be starting (this is normal, it can take up to 60 seconds)"; \
	else \
		echo "  ✓ Kafka broker is ready"; \
	fi
	@echo "✓ Kafka cluster started"

# Stop Kafka cluster
stop:
	@echo "Stopping Kafka cluster..."
	@docker-compose -f docker-compose.yml down

# Restart Kafka cluster
restart: stop start

# View Kafka logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check Kafka container status
status:
	@echo "Kafka Cluster Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=kafka" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@docker ps --filter "name=zookeeper" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up Kafka (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all Kafka containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up Kafka resources"; \
	else \
		echo "Cancelled."; \
	fi

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Running basic connectivity test..."; \
		echo "Testing Kafka connectivity..."; \
		if docker ps | grep -q kafka; then \
			echo "✓ Kafka container is running"; \
		else \
			echo "✗ Kafka container is not running"; \
			exit 1; \
		fi; \
	fi

