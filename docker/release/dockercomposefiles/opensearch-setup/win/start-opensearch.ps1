# PowerShell script to start OpenSearch
# For Windows with Docker Desktop or WSL2

Write-Host "Starting OpenSearch cluster for Windows..." -ForegroundColor Green
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠ Warning: .env file not found. Creating one with default password..." -ForegroundColor Yellow
    "OPENSEARCH_INITIAL_ADMIN_PASSWORD=MySecure123!" | Out-File -FilePath ".env" -Encoding utf8
    Write-Host "✓ Created .env file. You can edit it to change the password." -ForegroundColor Green
    Write-Host ""
}

# Note: On Windows with Docker Desktop, vm.max_map_count is typically set automatically
# If you're using WSL2, you may need to set it in the WSL2 instance:
# wsl sudo sysctl -w vm.max_map_count=262144

Write-Host "Starting OpenSearch cluster..." -ForegroundColor Green
Write-Host ""

# Start docker-compose
docker-compose -f docker-compose.yml up

