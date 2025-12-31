#!/bin/bash

# Test script for MinIO (S3-compatible) functionality
# This script tests basic S3 operations using MinIO

set -e

echo "========================================="
echo "MinIO (S3-compatible) Functionality Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENDPOINT="http://localhost:9000"
ACCESS_KEY="minioadmin"
SECRET_KEY="minioadmin"
BUCKET_NAME="test-bucket-$(date +%s)"

# Check if container is running
echo "1. Checking if MinIO container is running..."
if docker ps | grep -q minio; then
    echo -e "${GREEN}✓ MinIO container is running${NC}"
else
    echo -e "${RED}✗ MinIO container is not running${NC}"
    echo "   Please run 'make start' first"
    exit 1
fi

echo ""
echo "2. Testing MinIO health endpoint..."
HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/minio/health/live || echo "000")
if [ "$HEALTH_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ MinIO health check passed (HTTP $HEALTH_RESPONSE)${NC}"
else
    echo -e "${RED}✗ MinIO health check failed (HTTP $HEALTH_RESPONSE)${NC}"
    exit 1
fi

echo ""
echo "3. Checking if mc (MinIO Client) is available..."
if command -v mc &> /dev/null; then
    echo -e "${GREEN}✓ mc (MinIO Client) is installed locally${NC}"
    MC_CMD="mc"
    MC_AVAILABLE=true
    # Use localhost for local mc
    MC_ENDPOINT="http://localhost:9000"
else
    echo -e "${YELLOW}⚠ mc (MinIO Client) is not installed locally${NC}"
    echo "   Using Docker container with mc for testing..."
    # Use --network container:minio to share network namespace with minio container
    MC_CMD="docker run --rm --network container:minio minio/mc:latest"
    MC_AVAILABLE=true
    # For Docker mc sharing network with minio, use localhost (same network namespace)
    MC_ENDPOINT="http://localhost:9000"
fi

echo ""
echo "4. Testing S3 API connectivity..."
# Test using curl to check if MinIO is responding
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 || echo "000")
if [ "$API_RESPONSE" = "403" ] || [ "$API_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ MinIO API is responding (HTTP $API_RESPONSE)${NC}"
else
    echo -e "${RED}✗ MinIO API is not responding correctly (HTTP $API_RESPONSE)${NC}"
    exit 1
fi

echo ""
echo "5. Testing S3 operations using mc (MinIO Client)..."
if [ "$MC_AVAILABLE" = true ]; then
    # Use the appropriate endpoint (MC_ENDPOINT for Docker, ENDPOINT for local)
    TEST_ENDPOINT=${MC_ENDPOINT:-$ENDPOINT}
    
    # For Docker mode, use MC_HOST_<alias> environment variable
    # For local mode, use aliases
    if [ "$MC_CMD" = "mc" ]; then
        # Local mode: set alias once
        ${MC_CMD} alias set testminio ${TEST_ENDPOINT} ${ACCESS_KEY} ${SECRET_KEY} > /dev/null 2>&1 || true
        ALIAS="testminio"
        MC_ENV=""
    else
        # Docker mode: use MC_HOST environment variable
        # Format: MC_HOST_<alias>=http://ACCESS_KEY:SECRET_KEY@host:port
        # Since we use --network container:minio, we can use localhost
        ALIAS="testminio"
        # Use localhost since we share network namespace with minio container
        MC_ENV="-e MC_HOST_${ALIAS}=http://${ACCESS_KEY}:${SECRET_KEY}@localhost:9000"
    fi
    
    # Create bucket
    if [ "$MC_CMD" = "mc" ]; then
        BUCKET_RESULT=$(${MC_CMD} mb ${ALIAS}/${BUCKET_NAME} 2>&1)
    else
        BUCKET_RESULT=$(docker run --rm ${MC_ENV} --network container:minio minio/mc:latest mb ${ALIAS}/${BUCKET_NAME} 2>&1)
    fi
    
    if [ $? -eq 0 ] || echo "$BUCKET_RESULT" | grep -q "already exists"; then
        echo -e "${GREEN}✓ Successfully created bucket: ${BUCKET_NAME}${NC}"
        
        # Create test content
        TEST_CONTENT="Test content $(date)"
        TEST_FILE_NAME="test-file.txt"
        
        # Upload file using pipe
        if [ "$MC_CMD" = "mc" ]; then
            # Local mode
            UPLOAD_RESULT=$(echo "${TEST_CONTENT}" | ${MC_CMD} pipe ${ALIAS}/${BUCKET_NAME}/${TEST_FILE_NAME} 2>&1)
        else
            # Docker mode: use environment variable
            UPLOAD_RESULT=$(echo "${TEST_CONTENT}" | docker run --rm -i ${MC_ENV} --network container:minio minio/mc:latest pipe ${ALIAS}/${BUCKET_NAME}/${TEST_FILE_NAME} 2>&1)
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Successfully uploaded file to S3${NC}"
            
            # Small delay to ensure file is available
            sleep 1
            
            # List objects
            if [ "$MC_CMD" = "mc" ]; then
                LIST_RESULT=$(${MC_CMD} ls ${ALIAS}/${BUCKET_NAME}/ 2>&1)
            else
                LIST_RESULT=$(docker run --rm ${MC_ENV} --network container:minio minio/mc:latest ls ${ALIAS}/${BUCKET_NAME}/ 2>&1)
            fi
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Successfully listed objects in bucket${NC}"
                
                # Download file content
                if [ "$MC_CMD" = "mc" ]; then
                    DOWNLOADED_CONTENT=$(${MC_CMD} cat ${ALIAS}/${BUCKET_NAME}/${TEST_FILE_NAME} 2>/dev/null || echo "")
                else
                    DOWNLOADED_CONTENT=$(docker run --rm ${MC_ENV} --network container:minio minio/mc:latest cat ${ALIAS}/${BUCKET_NAME}/${TEST_FILE_NAME} 2>/dev/null || echo "")
                fi
                
                if [ -n "$DOWNLOADED_CONTENT" ]; then
                    echo -e "${GREEN}✓ Successfully downloaded file from S3${NC}"
                    
                    # Compare content
                    if [ "$DOWNLOADED_CONTENT" = "$TEST_CONTENT" ]; then
                        echo -e "${GREEN}✓ File integrity verified (uploaded and downloaded files match)${NC}"
                    else
                        echo -e "${RED}✗ File integrity check failed${NC}"
                        echo "   Expected: ${TEST_CONTENT}"
                        echo "   Got: ${DOWNLOADED_CONTENT}"
                    fi
                else
                    echo -e "${RED}✗ Failed to download file content${NC}"
                fi
            else
                echo -e "${RED}✗ Failed to list objects${NC}"
                echo "   Error: $LIST_RESULT"
            fi
            
            # Delete object
            if [ "$MC_CMD" = "mc" ]; then
                DELETE_RESULT=$(${MC_CMD} rm ${ALIAS}/${BUCKET_NAME}/${TEST_FILE_NAME} 2>&1)
            else
                DELETE_RESULT=$(docker run --rm ${MC_ENV} --network container:minio minio/mc:latest rm ${ALIAS}/${BUCKET_NAME}/${TEST_FILE_NAME} 2>&1)
            fi
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Successfully deleted object from S3${NC}"
            fi
        else
            echo -e "${RED}✗ Failed to upload file${NC}"
            echo "   Error: $UPLOAD_RESULT"
        fi
        
        # Remove bucket
        if [ "$MC_CMD" = "mc" ]; then
            ${MC_CMD} rb ${ALIAS}/${BUCKET_NAME} > /dev/null 2>&1 || true
        else
            docker run --rm ${MC_ENV} --network container:minio minio/mc:latest rb ${ALIAS}/${BUCKET_NAME} > /dev/null 2>&1 || true
        fi
    else
        echo -e "${RED}✗ Failed to create bucket${NC}"
        echo "   Error: $BUCKET_RESULT"
    fi
    
    # Remove alias (only for local mc)
    if [ "$MC_CMD" = "mc" ]; then
        ${MC_CMD} alias remove testminio > /dev/null 2>&1 || true
    fi
else
    echo -e "${YELLOW}⚠ Skipping S3 operations test (mc not available)${NC}"
    echo "   To test S3 operations, install mc:"
    echo "   - macOS: brew install minio/stable/mc"
    echo "   - Linux: wget https://dl.min.io/client/mc/release/linux-amd64/mc && chmod +x mc"
    echo "   - Or use AWS CLI with: aws --endpoint-url=http://localhost:9000 s3 ls"
fi

echo ""
echo "6. Testing MinIO Console accessibility..."
CONSOLE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9001 || echo "000")
if [ "$CONSOLE_RESPONSE" = "200" ] || [ "$CONSOLE_RESPONSE" = "302" ]; then
    echo -e "${GREEN}✓ MinIO Console is accessible (HTTP $CONSOLE_RESPONSE)${NC}"
    echo "   Access at: http://localhost:9001"
else
    echo -e "${YELLOW}⚠ MinIO Console check returned HTTP $CONSOLE_RESPONSE${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="
echo ""
echo "MinIO is ready to use:"
echo "  - API Endpoint: http://localhost:9000"
echo "  - Console: http://localhost:9001"
echo "  - Credentials: minioadmin / minioadmin"
echo ""
echo "You can use this with any S3-compatible client:"
echo "  - AWS CLI: aws --endpoint-url=http://localhost:9000 s3 ls"
echo "  - MinIO Client (mc): mc alias set local http://localhost:9000 minioadmin minioadmin"
echo "  - boto3 (Python): Use endpoint_url='http://localhost:9000'"
echo "  - Any S3 SDK with endpoint configuration"

