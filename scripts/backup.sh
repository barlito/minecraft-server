#!/bin/bash
set -e

# Minecraft Server - Automated Backup Script
# Usage: ./backup.sh [backup_directory] [retention_days]

BACKUP_DIR="${1:-./backups}"
RETENTION_DAYS="${2:-7}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="minecraft-backup-$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

echo "======================================"
echo "Minecraft Server Backup"
echo "======================================"
echo "Timestamp: $TIMESTAMP"
echo "Backup directory: $BACKUP_DIR"
echo "Retention period: $RETENTION_DAYS days"
echo ""

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Save world before backup (if server is running)
echo "[1/4] Saving world..."
if docker-compose ps -q mc &>/dev/null && [ -n "$(docker-compose ps -q mc)" ]; then
    docker-compose exec -T mc rcon-cli /save-all || echo "Warning: Could not save world (server might be stopped)"
    sleep 2
else
    echo "Server is not running, skipping world save..."
fi

# Create backup
echo "[2/4] Creating backup archive..."
tar -czf "$BACKUP_PATH" \
    --exclude='*.log' \
    --exclude='*.log.gz' \
    --exclude='crash-reports' \
    minecraft-data \
    worlds \
    mods \
    plugins \
    modpacks \
    docker-compose.yaml \
    Makefile \
    .gitignore 2>/dev/null || true

echo "Backup created: $BACKUP_PATH"
BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
echo "Backup size: $BACKUP_SIZE"

# Clean old backups
echo "[3/4] Cleaning old backups (older than $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "minecraft-backup-*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
REMAINING_BACKUPS=$(find "$BACKUP_DIR" -name "minecraft-backup-*.tar.gz" -type f | wc -l)
echo "Remaining backups: $REMAINING_BACKUPS"

# Display backup info
echo "[4/4] Backup summary:"
echo ""
ls -lh "$BACKUP_DIR"/minecraft-backup-*.tar.gz | tail -5

echo ""
echo "======================================"
echo "Backup completed successfully!"
echo "======================================"
echo "Latest backup: $BACKUP_PATH"
echo ""
echo "To restore from this backup:"
echo "  tar -xzf $BACKUP_PATH"
