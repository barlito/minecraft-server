# Minecraft Server - Youlz

A production-ready, containerized Minecraft Fabric server with easy deployment and management.

## Quick Start

```bash
# Clone the repository
git clone git@github.com:barlito/minecraft-server.git
cd minecraft-server

# Copy your modpack file (.mrpack) to the server
# Example:
scp ~/Downloads/your-modpack.mrpack user@server:/path/to/minecraft-server/modpacks/modpack.mrpack

# If using custom SSH port, add -P flag:
# scp -P 3333 ~/Downloads/your-modpack.mrpack user@server:/path/to/minecraft-server/modpacks/modpack.mrpack

# Start the server
make deploy

# View logs
make logs
```

The server will be available on port `20242`.

## Prerequisites

- Docker
- Docker Compose
- Make (optional, for convenience commands)

## Server Configuration

### Environment Variables

All server configuration is managed via environment variables in `docker-compose.yaml`:

```yaml
EULA: "TRUE"                         # Accept Mojang EULA
DIFFICULTY: "hard"                   # Difficulty level
SERVER_NAME: "Youlz Server"          # Server name
TYPE: "MODRINTH"                     # Use Modrinth modpack
MODRINTH_MODPACK: "/modpacks/modpack.mrpack"  # Path to .mrpack file
MEMORY: 8G                           # RAM allocation
VIEW_DISTANCE: 32                    # Chunk view distance
ENABLE_AUTOPAUSE: "TRUE"             # Auto-pause when empty
ENABLE_WHITELIST: "TRUE"             # Whitelist enabled
MAX_TICK_TIME: -1                    # Disable tick timeout (prevents autopause crash)
```

To modify settings, edit `docker-compose.yaml` and restart the server with `make restart`.

### Operators and Whitelist

Operators and whitelisted players are defined in the `docker-compose.yaml` file:

```yaml
OPS: "Username,UUID,AnotherUser,UUID"
WHITELIST: "Username,UUID,AnotherUser,UUID"
```

Changes require a server restart to take effect.

## Data Persistence

All server data is persisted in local directories via Docker volumes:

```
minecraft-server/
├── minecraft-data/    # Server files (configs, logs, server.properties)
├── worlds/            # World saves (read-only mount)
├── mods/              # Fabric mods
├── plugins/           # Server plugins
└── modpacks/          # Modpack files
```

**Important**: These directories are excluded from Git. Only `.gitkeep` files are tracked to maintain the directory structure.

## Custom Modpack Deployment

This server is configured to use Modrinth modpack files (.mrpack format).

### Deploying a Modpack

**Step 1: Get your .mrpack file**

Download your modpack from Modrinth or export it from your launcher (Prism, ATLauncher, etc.)

**Step 2: Copy to server**

```bash
# Copy the modpack file to the server
scp /path/to/your/modpack.mrpack user@server:/path/to/minecraft-server/modpacks/modpack.mrpack

# Example:
scp ~/Downloads/cobbleverse-1.7.2.mrpack user@server:/home/user/minecraft-server/modpacks/modpack.mrpack

# If using custom SSH port, add -P flag:
# scp -P 2222 ~/Downloads/modpack.mrpack user@server:/path/to/minecraft-server/modpacks/modpack.mrpack
```

**Step 3: Deploy the server**

```bash
# SSH into the server (add -p PORT if using custom SSH port)
ssh user@server

# Navigate to server directory
cd /path/to/minecraft-server

# Restart the server (it will automatically use the new modpack)
make restart
```

### Modifying a Modpack

If you want to customize a modpack (add/remove mods):

1. **Download the base modpack** from Modrinth
2. **Extract and modify** it locally using a launcher or manually
3. **Export as .mrpack** from your launcher
4. **Copy to server** using the scp command above
5. **Restart** with `make restart`

**Important**: The server automatically installs mods from the .mrpack file. Your customizations will persist as long as you keep your modified .mrpack file.

### Switching Between Modpacks

```bash
# 1. Stop the server
make undeploy

# 2. Backup current data
make backup

# 3. Clean old modpack data
rm -rf ./minecraft-data/*
rm -rf ./mods/*

# 4. Copy new .mrpack file (add -P PORT if using custom SSH port)
scp new-modpack.mrpack user@server:/path/to/minecraft-server/modpacks/modpack.mrpack

# 5. Start with new modpack
make deploy
```

## Custom World/Map Setup

To add a custom world or pre-built map:

### Option 1: Replace existing world

```bash
# 1. Stop the server
make undeploy

# 2. Copy your custom world folder
cp -r /path/to/your/custom-world/* ./worlds/

# 3. Configure world name in docker-compose.yaml
# Add this environment variable:
WORLD: /worlds/your-world-folder-name

# 4. Restart the server
make deploy
```

### Option 2: Fresh world import

```bash
# 1. Ensure server is stopped
make undeploy

# 2. Clear existing world data (backup first!)
make backup
rm -rf ./minecraft-data/world*

# 3. Copy custom world to worlds directory
cp -r /path/to/custom-world ./worlds/my-custom-world

# 4. Update docker-compose.yaml
# Add/modify:
WORLD: /worlds/my-custom-world

# 5. Start server
make deploy
```

**Note**: The `worlds` directory is mounted as **read-only** to prevent accidental modifications. The server will copy it to `/data/world` on first run.

## World Chunk Preloading

Preloading chunks improves player experience by generating terrain in advance and reducing lag.

### Using Chunky (Recommended)

Chunky is a fast chunk pregenerator. It's already included if your modpack has it, or you can add it:

```bash
# 1. Download Chunky for Fabric
wget -O mods/Chunky-1.3.92.jar \
  https://cdn.modrinth.com/data/fALzjamp/versions/YOUR_VERSION/Chunky-Fabric-1.20.6.jar

# 2. Restart server
make restart

# 3. Attach to server console
make console

# 4. Run preload commands
chunky world YOUR_WORLD_NAME
chunky center 0 0
chunky radius 5000
chunky start

# 5. Monitor progress
chunky progress

# 6. Detach from console: Ctrl+P, Ctrl+Q
```

### Preload Configuration

Common preload scenarios:

```bash
# Small server (radius 3000 blocks = ~28M blocks)
chunky radius 3000
chunky start

# Medium server (radius 5000 blocks = ~78M blocks)
chunky radius 5000
chunky start

# Large server (radius 10000 blocks = ~314M blocks)
chunky radius 10000
chunky start

# Custom shape (square instead of circle)
chunky shape square
chunky radius 5000
chunky start
```

**Estimated times** (depends on hardware):
- 3000 radius: 30-60 minutes
- 5000 radius: 2-4 hours
- 10000 radius: 10-20 hours

**Tip**: Run preload overnight or during low-traffic periods. The server remains playable during preloading, but may experience slight lag.

### Preload best practices

1. **Start small, expand later**: Begin with a smaller radius and expand as needed
2. **Use autopause**: Disable autopause during preload to prevent interruptions:
   ```yaml
   ENABLE_AUTOPAUSE: "FALSE"
   ```
   Re-enable after preloading completes.
3. **Monitor server resources**: Use `docker stats` to monitor CPU/RAM usage
4. **Pause preload if needed**: `chunky pause` in the console

## Available Commands

All commands use the `Makefile` for convenience:

```bash
make deploy        # Start the server
make undeploy      # Save world and stop the server
make stop          # Stop the server without saving (useful if server crashed)
make restart       # Full restart (save + stop + start)
make logs          # Stream server logs (Ctrl+C to exit)
make status        # Show container status
make bash          # Access container shell as root
make console       # Attach to server console (Ctrl+P, Ctrl+Q to detach)
make save-world    # Manually save the world
make backup        # Create timestamped backup of all data
make send-message  # Send in-game message (use MESSAGE='text')
make help          # Show all available commands
```

### Examples

```bash
# Send a message to players
make send-message MESSAGE="Server restart in 5 minutes!"

# Create a backup before major changes
make backup

# Access server console to run commands
make console
# (In console) /whitelist add PlayerName
# (Detach) Ctrl+P, Ctrl+Q

# Monitor server logs in real-time
make logs
```

## Backup Strategy

### Manual Backup

```bash
# Create a backup
make backup

# This creates: backup-YYYYMMDD-HHMMSS.tar.gz
# Containing: minecraft-data, worlds, mods, plugins, modpacks
```

### Automated Backups

Set up a cron job for automatic backups:

```bash
# Edit crontab
crontab -e

# Add daily backup at 3 AM
0 3 * * * cd /path/to/minecraft-server && make backup

# Keep only last 7 backups
0 4 * * * cd /path/to/minecraft-server && ls -t backup-*.tar.gz | tail -n +8 | xargs -r rm
```

### Backup to Remote Storage

```bash
# Example: rsync to remote backup server
make backup
rsync -avz backup-*.tar.gz user@backup-server:/backups/minecraft/
```

## Server Management

### Viewing Server Status

```bash
# Container status
make status

# Server logs
make logs

# Resource usage
docker stats
```

### Updating Minecraft Version

```bash
# 1. Stop the server
make undeploy

# 2. Backup everything
make backup

# 3. Edit docker-compose.yaml
# Change: VERSION: 1.20.6
# To:     VERSION: 1.21.0  (or desired version)

# 4. Update mods to match new version (if needed)

# 5. Restart
make deploy
```

### Updating Mods

```bash
# 1. Stop the server
make undeploy

# 2. Backup current mods
cp -r mods mods.backup

# 3. Update mod files (rsync, manual copy, etc.)
rsync -avz user@local:/path/to/updated/mods/ ./mods/

# 4. Restart server
make deploy

# 5. Test thoroughly, rollback if issues
# make undeploy
# rm -rf mods && mv mods.backup mods
# make deploy
```

## Troubleshooting

### Server won't start

```bash
# Check logs for errors
make logs

# Common issues:
# - EULA not accepted: Set EULA: "TRUE" in docker-compose.yaml
# - Port conflict: Change port mapping in docker-compose.yaml
# - Insufficient memory: Reduce MEMORY value or increase host RAM
```

### Container exits immediately

```bash
# Check exit reason
docker-compose logs mc

# Verify configuration
docker-compose config
```

### Autopause causing crashes

If autopause causes issues:

```yaml
# In docker-compose.yaml
ENABLE_AUTOPAUSE: "FALSE"
MAX_TICK_TIME: -1  # Already set, but verify
```

### Makefile commands not working

```bash
# Verify container is running
docker-compose ps

# If container name is different, check with:
docker ps

# Manually run commands:
docker exec -it <container_name> rcon-cli /save-all
```

### Can't connect to server

```bash
# 1. Verify server is running
make status

# 2. Check if port is open
netstat -tuln | grep 20242

# 3. Check firewall rules
sudo ufw status

# 4. Verify whitelist (if enabled)
make bash
cat /data/whitelist.json
```

## Advanced Configuration

### Changing Server Port

```yaml
# In docker-compose.yaml, modify:
ports:
  - 25565:25565  # Change left number (host port)
```

### Adding More Operators

```yaml
# In docker-compose.yaml
OPS: "User1,UUID1,User2,UUID2,User3,UUID3"
```

Find player UUIDs at: https://mcuuid.net/

### Performance Tuning

For better performance, adjust:

```yaml
VIEW_DISTANCE: 16        # Reduce from 32 (less chunk loading)
MEMORY: 12G              # Increase RAM if available
MAX_TICK_TIME: -1        # Keep disabled for autopause
```

Add performance mods:
- Lithium (server-side optimization)
- Phosphor (lighting engine optimization)
- Starlight (chunk loading optimization)

## Security

- **Whitelist**: Enabled by default - only approved players can join
- **Operators**: Limited to trusted users only
- **Port exposure**: Only Minecraft port (20242) is exposed
- **Backups**: Regular backups protect against data loss
- **Read-only world mount**: Prevents accidental world corruption

## Credits

- Docker image: [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server)
- Fabric mod loader: [FabricMC](https://fabricmc.net/)

## License

This configuration repository is provided as-is. Minecraft is property of Mojang Studios.

---

**Need help?** Check the [itzg/minecraft-server documentation](https://docker-minecraft-server.readthedocs.io/en/latest/)
