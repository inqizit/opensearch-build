# Multi-Service Development Environment

A comprehensive Docker-based development environment for widely used databases, message queues, and analytics tools.

## Supported Services

### Search & Analytics
- **OpenSearch** - Search and analytics engine (Elasticsearch alternative)
- **DuckDB** - In-process analytical database
- **ClickHouse** - Column-oriented database for real-time analytics

### Message Queues
- **Kafka** - Distributed event streaming platform

### Databases
- **PostgreSQL** - Advanced open-source relational database
- **MongoDB** - NoSQL document database
- **Cassandra** - Distributed NoSQL database
- **Redis** - In-memory data structure store
- **Neo4j** - Graph database

## Quick Start

### Start All Services
```bash
make start
```

### Start Individual Service
```bash
make opensearch-start
make kafka-start
make postgres-start
make mongo-start
make cassandra-start
make redis-start
make duckdb-start
make neo4j-start
make clickhouse-start
```

### Test All Services
```bash
make test
```

### Check Status
```bash
make status
```

## Service Details

### OpenSearch
- **UI**: http://localhost:5601
- **API**: http://localhost:9200
- **Credentials**: admin / (check .env file)

### Kafka
- **Broker**: localhost:9092
- **Zookeeper**: localhost:2181
- **UI**: http://localhost:8080

### PostgreSQL
- **Port**: localhost:5432
- **pgAdmin**: http://localhost:8083
- **Credentials**: admin / password123

### MongoDB
- **Port**: localhost:27017
- **Mongo Express**: http://localhost:8082
- **Credentials**: admin / password123

### Cassandra
- **Port**: localhost:9042
- **CQL Shell**: Use `make cassandra-shell` to access cqlsh

### Redis
- **Port**: localhost:6379
- **Redis Commander**: http://localhost:8081

### DuckDB
- **HTTP API**: http://localhost:8000
- **Note**: DuckDB is primarily an embedded database. Install via:
  - Python: `pip install duckdb`
  - Node.js: `npm install duckdb`

### Neo4j
- **Browser**: http://localhost:7474
- **Bolt**: localhost:7687
- **Credentials**: neo4j / password123

### ClickHouse
- **HTTP API**: http://localhost:8123
- **Native**: localhost:9000
- **Tabix UI**: http://localhost:8084
- **Credentials**: default / (empty)

## Additional Technologies (Not Included)

### Cloud-Only Services
- **BigQuery** - Google's cloud data warehouse (requires GCP account)
  - Use Google Cloud SDK for local development
  - BigQuery Emulator: https://github.com/goccy/bigquery-emulator

### Other Popular Technologies to Consider
- **InfluxDB** - Time-series database
- **Elasticsearch** - Search engine (similar to OpenSearch)
- **RabbitMQ** - Message broker (alternative to Kafka)
- **TimescaleDB** - PostgreSQL extension for time-series data
- **ScyllaDB** - High-performance Cassandra alternative
- **CouchDB** - Document database
- **DynamoDB Local** - AWS DynamoDB local emulator

## Directory Structure

Each service has its own directory with:
- `docker-compose.yml` - Service configuration
- `Makefile` - Self-sufficient management commands
- `test.sh` - Comprehensive functionality tests

## Usage Examples

### Individual Service Management
```bash
# OpenSearch
cd opensearch/linux && make start && make test

# Kafka
cd kafka && make start && make test

# PostgreSQL
cd postgres && make start && make test
```

### From Root Directory
```bash
# Start specific service
make kafka-start

# Test specific service
make postgres-test

# View logs
make kafka-logs

# Check status
make status
```

## Data Persistence

All service data is stored in the `data/` directory at the repository root:
- Data persists across container restarts
- Data is stored locally using bind mounts (not Docker volumes)
- The `data/` directory is git-ignored and will not be committed
- To reset a service, delete its data directory and restart the service

### Data Directory Structure
```
data/
├── kafka/          # Kafka and Zookeeper data
├── postgres/       # PostgreSQL and pgAdmin data
├── mongo/          # MongoDB data
├── redis/          # Redis data
├── cassandra/      # Cassandra data
├── neo4j/          # Neo4j data, logs, plugins
├── clickhouse/     # ClickHouse data and logs
├── duckdb/         # DuckDB database files
└── opensearch/     # OpenSearch node data
```

## Notes

- All services are configured with default credentials for development
- Data persists across restarts in the `data/` directory
- Each service can be managed independently
- All services include comprehensive test scripts
- To completely reset a service: delete its data directory and restart

