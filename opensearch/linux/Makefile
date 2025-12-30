# Makefile for OpenSearch - Self-Sufficient
# Copyright OpenSearch Contributors
# SPDX-License-Identifier: Apache-2.0

.PHONY: help start stop restart logs status check clean shell urls test

# Default target
help:
	@echo "OpenSearch Management - Available Commands:"
	@echo ""
	@echo "  make start      - Start OpenSearch cluster (with vm.max_map_count setup)"
	@echo "  make stop       - Stop OpenSearch cluster"
	@echo "  make restart   - Restart OpenSearch cluster"
	@echo "  make logs       - View OpenSearch logs (follow mode)"
	@echo "  make status     - Check OpenSearch container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open shell in opensearch-node1 container"
	@echo "  make urls       - Show access URLs and test connectivity"
	@echo "  make test       - Run test script to verify functionality"
	@echo ""
	@echo "Quick Access:"
	@echo "  OpenSearch UI:    http://localhost:5601"
	@echo "  OpenSearch API:   http://localhost:9200"
	@echo "  Default username: admin"
	@echo "  Default password: Check .env file"

# Check Docker connectivity before operations
check:
	@if [ -f "check-docker.sh" ]; then \
		./check-docker.sh; \
	else \
		echo "Checking Docker connectivity..."; \
		if docker ps &> /dev/null; then \
			echo "✓ Docker daemon is accessible!"; \
		else \
			echo "✗ Cannot connect to Docker daemon"; \
			echo "  Make sure Docker/Rancher Desktop is running and WSL integration is enabled"; \
			exit 1; \
		fi; \
	fi

# Start OpenSearch cluster
start: check
	@echo "Starting OpenSearch cluster..."
	@if [ -f "start-opensearch.sh" ]; then \
		./start-opensearch.sh; \
	else \
		echo "⚠ start-opensearch.sh not found, using docker-compose directly..."; \
		if [ ! -f .env ]; then \
			echo "OPENSEARCH_INITIAL_ADMIN_PASSWORD=MySecure123!" > .env; \
		fi; \
		docker-compose -f docker-compose.yml up -d; \
	fi

# Stop OpenSearch cluster
stop:
	@echo "Stopping OpenSearch cluster..."
	@docker-compose -f docker-compose.yml down

# Restart OpenSearch cluster
restart: stop start

# View OpenSearch logs
logs:
	@docker-compose -f docker-compose.yml logs -f

# Check OpenSearch container status
status:
	@echo "OpenSearch Cluster Status:"
	@echo ""
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=opensearch" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up OpenSearch (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all OpenSearch containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up OpenSearch resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open shell in opensearch-node1 container
shell:
	@docker exec -it opensearch-node1 /bin/bash || \
	 docker exec -it opensearch-node1 /bin/sh

# Show access URLs and test connectivity
urls:
	@echo "OpenSearch Access URLs:"
	@echo ""
	@echo "From Windows Browser:"
	@echo "  UI:   http://localhost:5601"
	@echo "  API:  http://localhost:9200"
	@echo ""
	@echo "From WSL:"
	@WSL_IP=$$(hostname -I | awk '{print $$1}'); \
	 echo "  UI:   http://$$WSL_IP:5601 or http://localhost:5601"; \
	 echo "  API:  http://$$WSL_IP:9200 or http://localhost:9200"
	@echo ""
	@echo "Testing connectivity from WSL..."
	@echo -n "  Dashboards (5601): "; \
	 HTTP_CODE=$$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5601 2>/dev/null || echo "000"); \
	 if [ "$$HTTP_CODE" = "302" ] || [ "$$HTTP_CODE" = "200" ]; then \
		 echo "✓ Accessible (HTTP $$HTTP_CODE)"; \
	 else \
		 echo "✗ Not accessible (HTTP $$HTTP_CODE)"; \
	 fi
	@echo -n "  OpenSearch (9200): "; \
	 HTTP_CODE=$$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9200 2>/dev/null || echo "000"); \
	 if [ "$$HTTP_CODE" = "200" ] || [ "$$HTTP_CODE" = "401" ]; then \
		 echo "✓ Accessible (HTTP $$HTTP_CODE)"; \
	 else \
		 echo "✗ Not accessible (HTTP $$HTTP_CODE)"; \
	 fi
	@echo ""
	@echo "Default credentials:"
	@if [ -f ".env" ]; then \
		echo "  Username: admin"; \
		PASSWORD=$$(grep OPENSEARCH_INITIAL_ADMIN_PASSWORD .env | cut -d'=' -f2); \
		echo "  Password: $$PASSWORD"; \
	else \
		echo "  Username: admin"; \
		echo "  Password: (check .env file)"; \
	fi

# Run test script
test:
	@if [ -f "test.sh" ]; then \
		./test.sh; \
	else \
		echo "⚠ test.sh not found. Creating a basic test..."; \
		echo "Testing OpenSearch connectivity..."; \
		HTTP_CODE=$$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9200 2>/dev/null || echo "000"); \
		if [ "$$HTTP_CODE" = "200" ] || [ "$$HTTP_CODE" = "401" ]; then \
			echo "✓ OpenSearch is accessible (HTTP $$HTTP_CODE)"; \
		else \
			echo "✗ OpenSearch is not accessible (HTTP $$HTTP_CODE)"; \
			exit 1; \
		fi; \
	fi

