#!/bin/bash

# Script to start OpenSearch with proper vm.max_map_count setting
# For Linux systems

set -e

echo "Setting vm.max_map_count to 262144 for Linux..."
if sudo sysctl -w vm.max_map_count=262144 2>/dev/null; then
    echo "✓ Successfully set vm.max_map_count to 262144"
else
    echo "⚠ Could not set vm.max_map_count. You may need to:"
    echo "  1. Run with sudo privileges"
    echo "  2. Or set it permanently in /etc/sysctl.conf:"
    echo "     echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf"
    echo "     sudo sysctl -p"
    echo ""
    echo "Continuing anyway..."
fi

echo ""
echo "Verifying current vm.max_map_count value..."
CURRENT_VALUE=$(sysctl -n vm.max_map_count 2>/dev/null || echo "unknown")
echo "Current value: $CURRENT_VALUE (required: 262144)"
echo ""

if [ "$CURRENT_VALUE" != "262144" ] && [ "$CURRENT_VALUE" != "unknown" ]; then
    echo "⚠ Warning: vm.max_map_count is still $CURRENT_VALUE, not 262144"
    echo "OpenSearch may fail to start. Please configure it using one of the methods above."
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "Starting OpenSearch cluster..."
echo ""

# Change to the directory containing docker-compose file
cd "$(dirname "$0")"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠ Warning: .env file not found. Creating one with default password..."
    echo "OPENSEARCH_INITIAL_ADMIN_PASSWORD=MySecure123!" > .env
    echo "✓ Created .env file. You can edit it to change the password."
    echo ""
fi

# Start docker-compose
docker-compose -f docker-compose.yml up

