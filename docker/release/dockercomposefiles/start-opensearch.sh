#!/bin/bash

# Script to start OpenSearch with proper vm.max_map_count setting
# This is required for OpenSearch to run on macOS with Rancher Desktop

set -e

echo "Setting vm.max_map_count to 262144..."
if docker run --rm --privileged --pid=host alpine sh -c "sysctl -w vm.max_map_count=262144" 2>/dev/null; then
    echo "✓ Successfully set vm.max_map_count to 262144"
else
    echo "⚠ Could not set vm.max_map_count. You may need to:"
    echo "  1. Ensure Rancher Desktop allows privileged containers"
    echo "  2. Or configure it in Rancher Desktop settings"
    echo ""
    echo "Continuing anyway..."
fi

echo ""
echo "Verifying current vm.max_map_count value..."
CURRENT_VALUE=$(docker run --rm --privileged --pid=host alpine sh -c "sysctl -n vm.max_map_count" 2>/dev/null || echo "unknown")
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

# Start docker-compose
docker-compose -f docker-compose-default.x.yml up

