# Makefile for OpenSearch Build and Management
# Copyright OpenSearch Contributors
# SPDX-License-Identifier: Apache-2.0

.PHONY: help start stop restart logs status check clean shell

# Path to OpenSearch docker-compose setup
OPENSEARCH_DIR := docker/release/dockercomposefiles/opensearch-setup/linux
OPENSEARCH_COMPOSE := $(OPENSEARCH_DIR)/docker-compose.yml
OPENSEARCH_START_SCRIPT := $(OPENSEARCH_DIR)/start-opensearch.sh
OPENSEARCH_CHECK_SCRIPT := $(OPENSEARCH_DIR)/check-docker.sh

# Default target
help:
	@echo "OpenSearch Build - Available Commands:"
	@echo ""
	@echo "OpenSearch Management:"
	@echo "  make start      - Start OpenSearch cluster (with vm.max_map_count setup)"
	@echo "  make stop       - Stop OpenSearch cluster"
	@echo "  make restart   - Restart OpenSearch cluster"
	@echo "  make logs       - View OpenSearch logs (follow mode)"
	@echo "  make status     - Check OpenSearch container status"
	@echo "  make check      - Check Docker connectivity"
	@echo "  make clean      - Stop and remove containers, volumes, and networks"
	@echo "  make shell      - Open shell in opensearch-node1 container"
	@echo ""
	@echo "Quick Access:"
	@echo "  OpenSearch UI:    http://localhost:5601"
	@echo "  OpenSearch API:   http://localhost:9200"
	@echo "  Default username: admin"
	@echo "  Default password: Check $(OPENSEARCH_DIR)/.env file"

# Check Docker connectivity before operations
check:
	@if [ -f "$(OPENSEARCH_CHECK_SCRIPT)" ]; then \
		$(OPENSEARCH_CHECK_SCRIPT); \
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
	@if [ -f "$(OPENSEARCH_START_SCRIPT)" ]; then \
		cd $(OPENSEARCH_DIR) && ./start-opensearch.sh; \
	else \
		echo "⚠ start-opensearch.sh not found, using docker-compose directly..."; \
		cd $(OPENSEARCH_DIR) && docker-compose -f docker-compose.yml up -d; \
	fi

# Stop OpenSearch cluster
stop:
	@echo "Stopping OpenSearch cluster..."
	@cd $(OPENSEARCH_DIR) && docker-compose -f docker-compose.yml down

# Restart OpenSearch cluster
restart: stop start

# View OpenSearch logs
logs:
	@cd $(OPENSEARCH_DIR) && docker-compose -f docker-compose.yml logs -f

# Check OpenSearch container status
status:
	@echo "OpenSearch Cluster Status:"
	@echo ""
	@cd $(OPENSEARCH_DIR) && docker-compose -f docker-compose.yml ps
	@echo ""
	@echo "Container Health:"
	@docker ps --filter "name=opensearch" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up OpenSearch (stop, remove containers, volumes, networks)
clean:
	@echo "⚠ This will remove all OpenSearch containers, volumes, and networks!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd $(OPENSEARCH_DIR) && docker-compose -f docker-compose.yml down -v; \
		echo "✓ Cleaned up OpenSearch resources"; \
	else \
		echo "Cancelled."; \
	fi

# Open shell in opensearch-node1 container
shell:
	@docker exec -it opensearch-node1 /bin/bash || \
	 docker exec -it opensearch-node1 /bin/sh

