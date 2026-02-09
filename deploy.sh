#!/bin/bash

# Magento 2 Deployment Script for Hetzner Server
# Server IP: 89.167.21.190
# This script will install and configure Magento 2 on the server

set -e

echo "================================"
echo "Magento 2 Deployment Script"
echo "================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://89.167.21.190"
ADMIN_FIRSTNAME="Admin"
ADMIN_LASTNAME="User"
ADMIN_EMAIL="admin@magento.local"
ADMIN_USER="admin"
ADMIN_PASSWORD="Admin@123456"
DB_HOST="db"
DB_NAME="magento2"
DB_USER="magento2"
DB_PASSWORD="magento2"

echo -e "${GREEN}Step 1: Checking prerequisites...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}Docker installed successfully!${NC}"
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Installing Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully!${NC}"
else
    echo -e "${GREEN}Docker Compose is already installed.${NC}"
fi

echo ""
echo -e "${GREEN}Step 2: Starting Docker containers...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}Step 3: Waiting for services to be ready...${NC}"
echo "Waiting for MariaDB to be ready..."
sleep 30

# Wait for MariaDB
until docker-compose exec -T db mysqladmin ping -h"localhost" --silent; do
    echo "Waiting for database connection..."
    sleep 5
done
echo -e "${GREEN}MariaDB is ready!${NC}"

# Wait for Elasticsearch
echo "Waiting for Elasticsearch to be ready..."
until curl -s http://localhost:9200 >/dev/null; do
    echo "Waiting for Elasticsearch..."
    sleep 5
done
echo -e "${GREEN}Elasticsearch is ready!${NC}"

echo ""
echo -e "${GREEN}Step 4: Installing Composer dependencies...${NC}"
docker-compose exec -T web composer install --no-interaction --prefer-dist

echo ""
echo -e "${GREEN}Step 5: Running Magento installation...${NC}"
docker-compose exec -T web bin/magento setup:install \
    --base-url="${BASE_URL}/" \
    --db-host="${DB_HOST}" \
    --db-name="${DB_NAME}" \
    --db-user="${DB_USER}" \
    --db-password="${DB_PASSWORD}" \
    --admin-firstname="${ADMIN_FIRSTNAME}" \
    --admin-lastname="${ADMIN_LASTNAME}" \
    --admin-email="${ADMIN_EMAIL}" \
    --admin-user="${ADMIN_USER}" \
    --admin-password="${ADMIN_PASSWORD}" \
    --language=en_US \
    --currency=USD \
    --timezone=America/Chicago \
    --use-rewrites=1 \
    --search-engine=elasticsearch8 \
    --elasticsearch-host=elasticsearch \
    --elasticsearch-port=9200 \
    --elasticsearch-index-prefix=magento2 \
    --elasticsearch-enable-auth=0 \
    --elasticsearch-timeout=15 \
    --cleanup-database

echo ""
echo -e "${GREEN}Step 6: Configuring Magento...${NC}"
docker-compose exec -T web bin/magento config:set web/unsecure/base_url "${BASE_URL}/"
docker-compose exec -T web bin/magento config:set web/secure/base_url "${BASE_URL}/"
docker-compose exec -T web bin/magento config:set web/secure/use_in_frontend 0
docker-compose exec -T web bin/magento config:set web/secure/use_in_adminhtml 0

echo ""
echo -e "${GREEN}Step 7: Setting up cache...${NC}"
docker-compose exec -T web bin/magento setup:config:set \
    --cache-backend=redis \
    --cache-backend-redis-server=redis \
    --cache-backend-redis-db=0

docker-compose exec -T web bin/magento setup:config:set \
    --page-cache=redis \
    --page-cache-redis-server=redis \
    --page-cache-redis-db=1

docker-compose exec -T web bin/magento setup:config:set \
    --session-save=redis \
    --session-save-redis-host=redis \
    --session-save-redis-db=2

echo ""
echo -e "${GREEN}Step 8: Deploying static content...${NC}"
docker-compose exec -T web bin/magento setup:static-content:deploy -f

echo ""
echo -e "${GREEN}Step 9: Compiling DI...${NC}"
docker-compose exec -T web bin/magento setup:di:compile

echo ""
echo -e "${GREEN}Step 10: Setting file permissions...${NC}"
docker-compose exec -T web chmod -R 777 var/ generated/ pub/static/ pub/media/

echo ""
echo -e "${GREEN}Step 11: Enabling production mode...${NC}"
docker-compose exec -T web bin/magento deploy:mode:set production

echo ""
echo -e "${GREEN}Step 12: Flushing cache...${NC}"
docker-compose exec -T web bin/magento cache:flush

echo ""
echo -e "${GREEN}Step 13: Reindexing...${NC}"
docker-compose exec -T web bin/magento indexer:reindex

echo ""
echo "================================"
echo -e "${GREEN}Installation Complete!${NC}"
echo "================================"
echo ""
echo -e "Store URL: ${GREEN}${BASE_URL}${NC}"
echo -e "Admin URL: ${GREEN}${BASE_URL}/admin${NC}"
echo ""
echo -e "Admin Credentials:"
echo -e "  Username: ${YELLOW}${ADMIN_USER}${NC}"
echo -e "  Password: ${YELLOW}${ADMIN_PASSWORD}${NC}"
echo ""
echo -e "${YELLOW}Important:${NC} Please change the admin password after first login!"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To restart: docker-compose restart"
echo "To stop: docker-compose down"
echo ""
