#!/bin/bash

# Magento 2 Backup Script
# Run this regularly to backup your Magento installation

BACKUP_DIR="/opt/magento2-backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="magento2_backup_${DATE}"

echo "Starting Magento 2 backup..."

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Backup database
echo "Backing up database..."
docker-compose exec -T db mysqldump -umagento2 -pmagento2 magento2 > ${BACKUP_DIR}/${BACKUP_NAME}_db.sql

# Backup media files
echo "Backing up media files..."
tar -czf ${BACKUP_DIR}/${BACKUP_NAME}_media.tar.gz pub/media/

# Backup configuration
echo "Backing up configuration..."
tar -czf ${BACKUP_DIR}/${BACKUP_NAME}_config.tar.gz app/etc/

echo "Backup completed: ${BACKUP_DIR}/${BACKUP_NAME}_*"
echo ""
echo "Files created:"
ls -lh ${BACKUP_DIR}/${BACKUP_NAME}_*

# Clean up old backups (keep last 7 days)
echo ""
echo "Cleaning up old backups (keeping last 7 days)..."
find ${BACKUP_DIR} -type f -name "magento2_backup_*" -mtime +7 -delete
echo "Done!"
