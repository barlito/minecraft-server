#!/bin/bash
set -e

# Minecraft Server - Modpack Deployment Script
# Usage: ./deploy-modpack.sh /path/to/local/modpack [server_user@server_host:/path/to/minecraft-server]

MODPACK_PATH="$1"
SERVER_TARGET="${2:-user@server:/path/to/minecraft-server}"

if [ -z "$MODPACK_PATH" ]; then
    echo "Usage: $0 /path/to/local/modpack [user@server:/path/to/minecraft-server]"
    echo ""
    echo "Example:"
    echo "  $0 ~/my-modpack user@192.168.1.100:/home/user/minecraft-server"
    exit 1
fi

if [ ! -d "$MODPACK_PATH" ]; then
    echo "Error: Modpack directory not found: $MODPACK_PATH"
    exit 1
fi

echo "======================================"
echo "Minecraft Modpack Deployment"
echo "======================================"
echo "Local modpack: $MODPACK_PATH"
echo "Target server: $SERVER_TARGET"
echo ""

# Extract server details
SERVER_PATH="${SERVER_TARGET#*:}"
SERVER_HOST="${SERVER_TARGET%:*}"

# Check if mods directory exists in modpack
if [ -d "$MODPACK_PATH/mods" ]; then
    echo "[1/4] Deploying mods..."
    rsync -avz --progress "$MODPACK_PATH/mods/" "$SERVER_HOST:$SERVER_PATH/mods/"
    echo "Mods deployed successfully!"
else
    echo "[1/4] No mods directory found, skipping..."
fi

# Check if config directory exists
if [ -d "$MODPACK_PATH/config" ]; then
    echo "[2/4] Deploying config files..."
    rsync -avz --progress "$MODPACK_PATH/config/" "$SERVER_HOST:$SERVER_PATH/minecraft-data/config/"
    echo "Config files deployed successfully!"
else
    echo "[2/4] No config directory found, skipping..."
fi

# Check if modpacks directory exists
if [ -d "$MODPACK_PATH/modpacks" ]; then
    echo "[3/4] Deploying modpack files..."
    rsync -avz --progress "$MODPACK_PATH/modpacks/" "$SERVER_HOST:$SERVER_PATH/modpacks/"
    echo "Modpack files deployed successfully!"
else
    echo "[3/4] No modpacks directory found, skipping..."
fi

# Check if plugins directory exists
if [ -d "$MODPACK_PATH/plugins" ]; then
    echo "[4/4] Deploying plugins..."
    rsync -avz --progress "$MODPACK_PATH/plugins/" "$SERVER_HOST:$SERVER_PATH/plugins/"
    echo "Plugins deployed successfully!"
else
    echo "[4/4] No plugins directory found, skipping..."
fi

echo ""
echo "======================================"
echo "Deployment completed successfully!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. SSH into the server: ssh $SERVER_HOST"
echo "  2. Navigate to server directory: cd $SERVER_PATH"
echo "  3. Restart the server: make restart"
echo ""
echo "Or run remotely:"
echo "  ssh $SERVER_HOST 'cd $SERVER_PATH && make restart'"
