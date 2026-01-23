#!/bin/bash
set -e

# Minecraft Server - Custom World Deployment Script
# Usage: ./deploy-world.sh /path/to/world [world_name]

WORLD_PATH="$1"
WORLD_NAME="${2:-custom-world}"

if [ -z "$WORLD_PATH" ]; then
    echo "Usage: $0 /path/to/world [world_name]"
    echo ""
    echo "Example:"
    echo "  $0 ~/Downloads/my-awesome-world custom-world"
    echo ""
    echo "This will:"
    echo "  1. Stop the server"
    echo "  2. Backup current world"
    echo "  3. Copy new world to ./worlds/$WORLD_NAME"
    echo "  4. Configure server to use the new world"
    echo "  5. Restart the server"
    exit 1
fi

if [ ! -d "$WORLD_PATH" ]; then
    echo "Error: World directory not found: $WORLD_PATH"
    exit 1
fi

echo "======================================"
echo "Custom World Deployment"
echo "======================================"
echo "Source world: $WORLD_PATH"
echo "Target name: $WORLD_NAME"
echo ""

# Check if server is running
if docker-compose ps -q mc &>/dev/null && [ -n "$(docker-compose ps -q mc)" ]; then
    echo "[1/6] Stopping server..."
    make undeploy
else
    echo "[1/6] Server is already stopped"
fi

# Backup current world
echo "[2/6] Creating backup of current world..."
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
if [ -d "./worlds" ] && [ "$(ls -A ./worlds 2>/dev/null)" ]; then
    mkdir -p ./backups
    tar -czf "./backups/world-backup-$TIMESTAMP.tar.gz" ./worlds ./minecraft-data/world* 2>/dev/null || true
    echo "Backup created: ./backups/world-backup-$TIMESTAMP.tar.gz"
else
    echo "No existing world to backup"
fi

# Clean old world data
echo "[3/6] Cleaning old world data..."
rm -rf ./worlds/*
rm -rf ./minecraft-data/world*

# Copy new world
echo "[4/6] Copying new world..."
mkdir -p ./worlds
cp -r "$WORLD_PATH" "./worlds/$WORLD_NAME"
echo "World copied to: ./worlds/$WORLD_NAME"

# Configure docker-compose.yaml
echo "[5/6] Configuring server to use new world..."

# Check if WORLD variable exists in docker-compose.yaml
if grep -q "WORLD:" docker-compose.yaml; then
    # Update existing WORLD variable
    sed -i "s|WORLD:.*|WORLD: \"/worlds/$WORLD_NAME\"|" docker-compose.yaml
    echo "Updated WORLD variable in docker-compose.yaml"
else
    # Add WORLD variable after VERSION line
    sed -i "/VERSION:/a\      WORLD: \"/worlds/$WORLD_NAME\"" docker-compose.yaml
    echo "Added WORLD variable to docker-compose.yaml"
fi

# Restart server
echo "[6/6] Starting server with new world..."
make deploy

echo ""
echo "======================================"
echo "World deployment completed!"
echo "======================================"
echo "World name: $WORLD_NAME"
echo "World path: /worlds/$WORLD_NAME"
echo ""
echo "The server is now starting with your custom world."
echo "Check logs: make logs"
echo ""
echo "If you need to rollback:"
echo "  1. Stop server: make undeploy"
echo "  2. Restore backup: tar -xzf ./backups/world-backup-$TIMESTAMP.tar.gz"
echo "  3. Restart: make deploy"
