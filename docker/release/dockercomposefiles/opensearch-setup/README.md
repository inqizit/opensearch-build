# OpenSearch Setup Files

This directory contains platform-specific setup files for running OpenSearch with Docker Compose.

## Directory Structure

```
opensearch-setup/
├── mac/          # macOS setup files (Rancher Desktop / Docker Desktop)
├── linux/        # Linux setup files
├── win/          # Windows setup files (Docker Desktop / WSL2)
└── README.md     # This file
```

Each platform directory contains:
- `start-opensearch.sh` (Mac/Linux) or `start-opensearch.ps1` (Windows) - Startup script
- `docker-compose.yml` - Docker Compose configuration
- `test-opensearch.md` - Testing guide

## Quick Start

### macOS

1. Navigate to the `mac/` directory:
   ```bash
   cd opensearch-setup/mac
   ```

2. Run the startup script:
   ```bash
   ./start-opensearch.sh
   ```

3. Access OpenSearch Dashboards at http://localhost:5601
   - Username: `admin`
   - Password: Check `.env` file (default: `MySecure123!`)

### Linux

1. Navigate to the `linux/` directory:
   ```bash
   cd opensearch-setup/linux
   ```

2. Run the startup script (may require sudo):
   ```bash
   ./start-opensearch.sh
   ```

3. Access OpenSearch Dashboards at http://localhost:5601
   - Username: `admin`
   - Password: Check `.env` file (default: `MySecure123!`)

### Windows

1. Navigate to the `win/` directory:
   ```powershell
   cd opensearch-setup\win
   ```

2. Run the PowerShell script:
   ```powershell
   .\start-opensearch.ps1
   ```

   Or if you prefer Command Prompt:
   ```cmd
   docker-compose -f docker-compose.yml up
   ```

3. Access OpenSearch Dashboards at http://localhost:5601
   - Username: `admin`
   - Password: Check `.env` file (default: `MySecure123!`)

## Configuration

### Environment Variables

Each platform directory can have a `.env` file to set the admin password:

```bash
OPENSEARCH_INITIAL_ADMIN_PASSWORD=YourSecurePassword123!
```

**Password Requirements (OpenSearch 2.12+ and 3.x):**
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character

### Docker Compose

The `docker-compose.yml` file configures:
- 2-node OpenSearch cluster
- OpenSearch Dashboards
- Persistent volumes for data
- Network configuration

## Platform-Specific Notes

### macOS
- Works with Rancher Desktop or Docker Desktop
- The script automatically sets `vm.max_map_count` using privileged containers
- If privileged containers are not allowed, configure Docker Desktop settings

### Linux
- Requires `sudo` to set `vm.max_map_count`
- To make it permanent, add to `/etc/sysctl.conf`:
  ```bash
  echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
  ```

### Windows
- Works with Docker Desktop or WSL2
- If using WSL2, you may need to set `vm.max_map_count` in WSL2:
  ```bash
  wsl sudo sysctl -w vm.max_map_count=262144
  ```

## Troubleshooting

### Connection Errors
If you see `getaddrinfo ENOTFOUND opensearch-node1`:
- Wait 1-2 minutes for OpenSearch nodes to fully start
- Check that OpenSearch containers are running: `docker ps`
- Verify the password is set correctly in `.env`

### vm.max_map_count Errors
- **macOS**: Ensure privileged containers are allowed
- **Linux**: Run with `sudo` or set permanently in `/etc/sysctl.conf`
- **Windows/WSL2**: Set in WSL2 instance: `wsl sudo sysctl -w vm.max_map_count=262144`

### Password Validation Errors
- Ensure password meets requirements (see Configuration section)
- Check `.env` file exists and has correct format

## Testing

See `test-opensearch.md` in each platform directory for:
- How to add sample data
- How to search using Dev Tools
- How to use Discover for visual search
- Example queries

## Stopping OpenSearch

Press `Ctrl+C` in the terminal, or in another terminal:

```bash
cd opensearch-setup/[platform]
docker-compose -f docker-compose.yml down
```

To remove all data:

```bash
docker-compose -f docker-compose.yml down -v
```

