# Makefile for Multi-Service Build and Management
# Supports: OpenSearch, Kafka, Redis, MongoDB, PostgreSQL, Cassandra, DuckDB

.PHONY: help start stop restart logs status check clean shell urls test
.PHONY: opensearch-start opensearch-stop opensearch-restart opensearch-logs opensearch-status opensearch-clean opensearch-shell opensearch-urls opensearch-test
.PHONY: kafka-start kafka-stop kafka-restart kafka-logs kafka-status kafka-clean kafka-test
.PHONY: redis-start redis-stop redis-restart redis-logs redis-status redis-clean redis-test
.PHONY: mongo-start mongo-stop mongo-restart mongo-logs mongo-status mongo-clean mongo-test
.PHONY: postgres-start postgres-stop postgres-restart postgres-logs postgres-status postgres-clean postgres-test
.PHONY: cassandra-start cassandra-stop cassandra-restart cassandra-logs cassandra-status cassandra-clean cassandra-shell cassandra-test
.PHONY: duckdb-start duckdb-stop duckdb-restart duckdb-logs duckdb-status duckdb-clean duckdb-shell duckdb-test

# Service directories
OPENSEARCH_DIR := opensearch/linux
KAFKA_DIR := kafka
REDIS_DIR := redis
MONGO_DIR := mongo
POSTGRES_DIR := postgres
CASSANDRA_DIR := cassandra
DUCKDB_DIR := duckdb

# Default target
help:
	@echo "Multi-Service Build - Available Commands:"
	@echo ""
	@echo "Service Management (all services):"
	@echo "  make start      - Start all services"
	@echo "  make stop       - Stop all services"
	@echo "  make restart   - Restart all services"
	@echo "  make status     - Check status of all services"
	@echo "  make test       - Run tests for all services"
	@echo ""
	@echo "OpenSearch Management:"
	@echo "  make opensearch-start    - Start OpenSearch cluster"
	@echo "  make opensearch-stop     - Stop OpenSearch cluster"
	@echo "  make opensearch-restart  - Restart OpenSearch cluster"
	@echo "  make opensearch-logs     - View OpenSearch logs"
	@echo "  make opensearch-status   - Check OpenSearch status"
	@echo "  make opensearch-clean    - Clean OpenSearch resources"
	@echo "  make opensearch-shell    - Open shell in opensearch-node1"
	@echo "  make opensearch-urls     - Show OpenSearch URLs"
	@echo "  make opensearch-test     - Test OpenSearch functionality"
	@echo ""
	@echo "Kafka Management:"
	@echo "  make kafka-start    - Start Kafka cluster"
	@echo "  make kafka-stop     - Stop Kafka cluster"
	@echo "  make kafka-restart  - Restart Kafka cluster"
	@echo "  make kafka-logs     - View Kafka logs"
	@echo "  make kafka-status   - Check Kafka status"
	@echo "  make kafka-clean    - Clean Kafka resources"
	@echo "  make kafka-test     - Test Kafka functionality"
	@echo ""
	@echo "Redis Management:"
	@echo "  make redis-start    - Start Redis"
	@echo "  make redis-stop     - Stop Redis"
	@echo "  make redis-restart  - Restart Redis"
	@echo "  make redis-logs     - View Redis logs"
	@echo "  make redis-status   - Check Redis status"
	@echo "  make redis-clean    - Clean Redis resources"
	@echo "  make redis-test     - Test Redis functionality"
	@echo ""
	@echo "MongoDB Management:"
	@echo "  make mongo-start    - Start MongoDB"
	@echo "  make mongo-stop     - Stop MongoDB"
	@echo "  make mongo-restart  - Restart MongoDB"
	@echo "  make mongo-logs     - View MongoDB logs"
	@echo "  make mongo-status   - Check MongoDB status"
	@echo "  make mongo-clean    - Clean MongoDB resources"
	@echo "  make mongo-test     - Test MongoDB functionality"
	@echo ""
	@echo "PostgreSQL Management:"
	@echo "  make postgres-start    - Start PostgreSQL"
	@echo "  make postgres-stop     - Stop PostgreSQL"
	@echo "  make postgres-restart  - Restart PostgreSQL"
	@echo "  make postgres-logs     - View PostgreSQL logs"
	@echo "  make postgres-status   - Check PostgreSQL status"
	@echo "  make postgres-clean    - Clean PostgreSQL resources"
	@echo "  make postgres-test     - Test PostgreSQL functionality"
	@echo ""
	@echo "Cassandra Management:"
	@echo "  make cassandra-start    - Start Cassandra"
	@echo "  make cassandra-stop     - Stop Cassandra"
	@echo "  make cassandra-restart  - Restart Cassandra"
	@echo "  make cassandra-logs     - View Cassandra logs"
	@echo "  make cassandra-status   - Check Cassandra status"
	@echo "  make cassandra-clean    - Clean Cassandra resources"
	@echo "  make cassandra-shell    - Open Cassandra CQL shell"
	@echo "  make cassandra-test     - Test Cassandra functionality"
	@echo ""
	@echo "DuckDB Management:"
	@echo "  make duckdb-start    - Start DuckDB HTTP server"
	@echo "  make duckdb-stop     - Stop DuckDB"
	@echo "  make duckdb-restart  - Restart DuckDB"
	@echo "  make duckdb-logs     - View DuckDB logs"
	@echo "  make duckdb-status   - Check DuckDB status"
	@echo "  make duckdb-clean    - Clean DuckDB resources"
	@echo "  make duckdb-shell    - Open DuckDB CLI shell"
	@echo "  make duckdb-test     - Test DuckDB functionality"
	@echo ""
	@echo "Quick Access URLs:"
	@echo "  OpenSearch UI:    http://localhost:5601"
	@echo "  OpenSearch API:   http://localhost:9200"
	@echo "  Kafka:            localhost:9092"
	@echo "  Kafka UI:         http://localhost:8080"
	@echo "  Redis:            localhost:6379"
	@echo "  Redis Commander:  http://localhost:8081"
	@echo "  MongoDB:          localhost:27017"
	@echo "  Mongo Express:    http://localhost:8082"
	@echo "  PostgreSQL:       localhost:5432"
	@echo "  pgAdmin:          http://localhost:8083"
	@echo "  Cassandra:        localhost:9042"
	@echo "  DuckDB:           Use 'make duckdb-shell' or install locally (pip install duckdb)"

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

# Start all services
start: check
	@echo "Starting all services..."
	@$(MAKE) opensearch-start
	@$(MAKE) kafka-start
	@$(MAKE) redis-start
	@$(MAKE) mongo-start
	@$(MAKE) postgres-start
	@$(MAKE) cassandra-start
	@$(MAKE) duckdb-start

# Stop all services
stop:
	@echo "Stopping all services..."
	@$(MAKE) opensearch-stop
	@$(MAKE) kafka-stop
	@$(MAKE) redis-stop
	@$(MAKE) mongo-stop
	@$(MAKE) postgres-stop
	@$(MAKE) cassandra-stop
	@$(MAKE) duckdb-stop

# Restart all services
restart: stop start

# Status of all services
status:
	@echo "=== Service Status ==="
	@$(MAKE) opensearch-status
	@echo ""
	@$(MAKE) kafka-status
	@echo ""
	@$(MAKE) redis-status
	@echo ""
	@$(MAKE) mongo-status
	@echo ""
	@$(MAKE) postgres-status
	@echo ""
	@$(MAKE) cassandra-status
	@echo ""
	@$(MAKE) duckdb-status

# Test all services
test:
	@echo "Running tests for all services..."
	@$(MAKE) opensearch-test
	@$(MAKE) kafka-test
	@$(MAKE) redis-test
	@$(MAKE) mongo-test
	@$(MAKE) postgres-test
	@$(MAKE) cassandra-test
	@$(MAKE) duckdb-test

# OpenSearch targets
opensearch-start:
	@cd $(OPENSEARCH_DIR) && $(MAKE) start

opensearch-stop:
	@cd $(OPENSEARCH_DIR) && $(MAKE) stop

opensearch-restart:
	@cd $(OPENSEARCH_DIR) && $(MAKE) restart

opensearch-logs:
	@cd $(OPENSEARCH_DIR) && $(MAKE) logs

opensearch-status:
	@cd $(OPENSEARCH_DIR) && $(MAKE) status

opensearch-clean:
	@cd $(OPENSEARCH_DIR) && $(MAKE) clean

opensearch-shell:
	@cd $(OPENSEARCH_DIR) && $(MAKE) shell

opensearch-urls:
	@cd $(OPENSEARCH_DIR) && $(MAKE) urls

opensearch-test:
	@cd $(OPENSEARCH_DIR) && $(MAKE) test

# Kafka targets
kafka-start:
	@cd $(KAFKA_DIR) && $(MAKE) start

kafka-stop:
	@cd $(KAFKA_DIR) && $(MAKE) stop

kafka-restart:
	@cd $(KAFKA_DIR) && $(MAKE) restart

kafka-logs:
	@cd $(KAFKA_DIR) && $(MAKE) logs

kafka-status:
	@cd $(KAFKA_DIR) && $(MAKE) status

kafka-clean:
	@cd $(KAFKA_DIR) && $(MAKE) clean

kafka-test:
	@cd $(KAFKA_DIR) && $(MAKE) test

# Redis targets
redis-start:
	@cd $(REDIS_DIR) && $(MAKE) start

redis-stop:
	@cd $(REDIS_DIR) && $(MAKE) stop

redis-restart:
	@cd $(REDIS_DIR) && $(MAKE) restart

redis-logs:
	@cd $(REDIS_DIR) && $(MAKE) logs

redis-status:
	@cd $(REDIS_DIR) && $(MAKE) status

redis-clean:
	@cd $(REDIS_DIR) && $(MAKE) clean

redis-test:
	@cd $(REDIS_DIR) && $(MAKE) test

# MongoDB targets
mongo-start:
	@cd $(MONGO_DIR) && $(MAKE) start

mongo-stop:
	@cd $(MONGO_DIR) && $(MAKE) stop

mongo-restart:
	@cd $(MONGO_DIR) && $(MAKE) restart

mongo-logs:
	@cd $(MONGO_DIR) && $(MAKE) logs

mongo-status:
	@cd $(MONGO_DIR) && $(MAKE) status

mongo-clean:
	@cd $(MONGO_DIR) && $(MAKE) clean

mongo-test:
	@cd $(MONGO_DIR) && $(MAKE) test

# PostgreSQL targets
postgres-start:
	@cd $(POSTGRES_DIR) && $(MAKE) start

postgres-stop:
	@cd $(POSTGRES_DIR) && $(MAKE) stop

postgres-restart:
	@cd $(POSTGRES_DIR) && $(MAKE) restart

postgres-logs:
	@cd $(POSTGRES_DIR) && $(MAKE) logs

postgres-status:
	@cd $(POSTGRES_DIR) && $(MAKE) status

postgres-clean:
	@cd $(POSTGRES_DIR) && $(MAKE) clean

postgres-test:
	@cd $(POSTGRES_DIR) && $(MAKE) test

# Cassandra targets
cassandra-start:
	@cd $(CASSANDRA_DIR) && $(MAKE) start

cassandra-stop:
	@cd $(CASSANDRA_DIR) && $(MAKE) stop

cassandra-restart:
	@cd $(CASSANDRA_DIR) && $(MAKE) restart

cassandra-logs:
	@cd $(CASSANDRA_DIR) && $(MAKE) logs

cassandra-status:
	@cd $(CASSANDRA_DIR) && $(MAKE) status

cassandra-clean:
	@cd $(CASSANDRA_DIR) && $(MAKE) clean

cassandra-shell:
	@cd $(CASSANDRA_DIR) && $(MAKE) shell

cassandra-test:
	@cd $(CASSANDRA_DIR) && $(MAKE) test

# DuckDB targets
duckdb-start:
	@cd $(DUCKDB_DIR) && $(MAKE) start

duckdb-stop:
	@cd $(DUCKDB_DIR) && $(MAKE) stop

duckdb-restart:
	@cd $(DUCKDB_DIR) && $(MAKE) restart

duckdb-logs:
	@cd $(DUCKDB_DIR) && $(MAKE) logs

duckdb-status:
	@cd $(DUCKDB_DIR) && $(MAKE) status

duckdb-clean:
	@cd $(DUCKDB_DIR) && $(MAKE) clean

duckdb-shell:
	@cd $(DUCKDB_DIR) && $(MAKE) shell

duckdb-test:
	@cd $(DUCKDB_DIR) && $(MAKE) test
