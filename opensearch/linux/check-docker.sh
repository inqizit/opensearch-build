#!/bin/bash
# Quick script to check Docker connectivity from WSL

echo "Checking Docker connectivity..."
echo ""

# Check if Docker CLI is available
if command -v docker &> /dev/null; then
    echo "✓ Docker CLI found: $(docker --version)"
else
    echo "✗ Docker CLI not found"
    exit 1
fi

# Check if Docker socket exists
if [ -S /var/run/docker.sock ]; then
    echo "✓ Docker socket found at /var/run/docker.sock"
else
    echo "✗ Docker socket NOT found at /var/run/docker.sock"
    echo ""
    echo "This means Rancher Desktop is not integrated with WSL."
    echo "Please:"
    echo "  1. Open Rancher Desktop on Windows"
    echo "  2. Go to Settings > WSL Integration"
    echo "  3. Enable integration for your WSL distribution"
    echo "  4. Click 'Apply & Restart'"
    exit 1
fi

# Test Docker connection
echo ""
echo "Testing Docker connection..."
if docker ps &> /dev/null; then
    echo "✓ Docker daemon is accessible!"
    echo ""
    echo "You can now run ./start-opensearch.sh"
else
    echo "✗ Cannot connect to Docker daemon"
    echo "Error: $(docker ps 2>&1)"
    exit 1
fi

