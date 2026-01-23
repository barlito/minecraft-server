# Helper Scripts

This directory contains utility scripts for managing the Minecraft server.

## Available Scripts

### 1. `deploy-modpack.sh`

Deploy a custom modpack from your local machine to the server via rsync.

```bash
./scripts/deploy-modpack.sh /path/to/local/modpack [user@server:/path/to/minecraft-server]
```

**What it does:**
- Syncs mods, config, modpacks, and plugins directories
- Uses rsync for efficient transfer (only changed files)
- Provides clear progress indicators

**Example:**
```bash
# Deploy modpack to remote server
./scripts/deploy-modpack.sh ~/my-modpack user@192.168.1.100:/home/minecraft/minecraft-server

# Deploy to local server
./scripts/deploy-modpack.sh ~/my-modpack root@localhost:/opt/minecraft-server
```

---

### 2. `backup.sh`

Create automated backups of all server data.

```bash
./scripts/backup.sh [backup_directory] [retention_days]
```

**What it does:**
- Saves the world before backing up (if server is running)
- Creates compressed archive of all important data
- Automatically cleans backups older than retention period
- Excludes logs and crash reports to save space

**Example:**
```bash
# Create backup in default location (./backups, 7 days retention)
./scripts/backup.sh

# Create backup in custom location with 30 days retention
./scripts/backup.sh /mnt/backup/minecraft 30

# Cron job for daily backups at 3 AM
0 3 * * * cd /path/to/minecraft-server && ./scripts/backup.sh
```

---

### 3. `deploy-world.sh`

Deploy a custom world/map to the server.

```bash
./scripts/deploy-world.sh /path/to/world [world_name]
```

**What it does:**
- Stops the server gracefully
- Backs up the current world
- Deploys the new world
- Updates docker-compose.yaml configuration
- Restarts the server with the new world

**Example:**
```bash
# Deploy a custom world
./scripts/deploy-world.sh ~/Downloads/epic-world custom-world

# Deploy a pre-built map
./scripts/deploy-world.sh /mnt/maps/skyblock skyblock-spawn
```

---

## Script Permissions

All scripts should be executable. If not, run:

```bash
chmod +x scripts/*.sh
```

## Advanced Usage

### Chaining Scripts

```bash
# Backup before deploying new modpack
./scripts/backup.sh && ./scripts/deploy-modpack.sh ~/new-modpack user@server:/minecraft

# Deploy world and create immediate backup
./scripts/deploy-world.sh ~/custom-world && ./scripts/backup.sh
```

### Remote Execution

```bash
# Run backup script on remote server via SSH
ssh user@server 'cd /path/to/minecraft-server && ./scripts/backup.sh'

# Automated remote backup to local machine
ssh user@server 'cd /minecraft && ./scripts/backup.sh /tmp 1' && \
  scp user@server:/tmp/minecraft-backup-*.tar.gz ./local-backups/
```

### Integration with Monitoring

```bash
# Send notification after backup
./scripts/backup.sh && curl -X POST https://hooks.slack.com/... \
  -d '{"text":"Minecraft backup completed"}'
```

## Troubleshooting

### Permission Denied

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run with sudo if needed (for system directories)
sudo ./scripts/backup.sh
```

### rsync Not Found

```bash
# Install rsync
# Ubuntu/Debian
sudo apt install rsync

# CentOS/RHEL
sudo yum install rsync
```

### Docker Commands Fail

Ensure:
- Docker is running: `systemctl status docker`
- You're in the correct directory (where docker-compose.yaml is)
- Container is running: `docker-compose ps`

## Creating Custom Scripts

Feel free to add your own scripts here! Follow these conventions:

1. **Use bash shebang**: `#!/bin/bash`
2. **Set error handling**: `set -e`
3. **Add usage instructions**: Show help when no arguments provided
4. **Make executable**: `chmod +x script.sh`
5. **Document in this README**: Add a section describing your script

Example template:

```bash
#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <argument>"
    exit 1
fi

# Your script logic here
echo "Doing something with: $1"
```
