#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}Security Tools Docker Setup${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""

# Create necessary directories
echo -e "${YELLOW}Creating workspace directories...${NC}"
mkdir -p workspace results scripts

# Build Docker image
echo -e "${YELLOW}Building Docker image (this may take 30-60 minutes)...${NC}"
docker build -t security-toolkit:latest .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build completed successfully!${NC}"
else
    echo -e "${RED}Build failed. Please check the error messages above.${NC}"
    exit 1
fi

# Run container
echo -e "${YELLOW}Starting container...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "To access the container, run:"
echo -e "${YELLOW}docker exec -it security-toolkit /bin/bash${NC}"
echo ""
echo -e "To stop the container, run:"
echo -e "${YELLOW}docker-compose down${NC}"
echo ""
echo -e "Workspace directory: ${YELLOW}./workspace${NC}"
echo -e "Results directory: ${YELLOW}./results${NC}"
echo ""