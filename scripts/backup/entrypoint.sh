#!/bin/bash

# Entrypoint script for the backup cron container
# This script sets up cron with environment variables and starts the cron daemon

set -e

echo "[$(date)] Starting backup service initialization..."

# Install cron if not already installed
if ! command -v cron &> /dev/null; then
    echo "[$(date)] Installing cron..."
    apt-get update
    apt-get install -y cron
fi

# Make backup scripts executable
chmod +x /scripts/*.sh

# Initialize backup user in database
echo "[$(date)] Initializing backup user..."
/scripts/init-backup-user.sh

# Generate crontab with current environment variables
CRONTAB_FILE="/etc/cron.d/backup-cron"
echo "[$(date)] Generating crontab with schedule: ${BACKUP_SCHEDULE}"

cat > "${CRONTAB_FILE}" << EOF
# AzerothCore Database Backup Crontab
# Auto-generated on $(date)
# Schedule: ${BACKUP_SCHEDULE}

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Environment variables for backup script
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
BACKUP_USER=${BACKUP_USER}
BACKUP_PASSWORD=${BACKUP_PASSWORD}
BACKUP_DIR=${BACKUP_DIR}
BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS}
BACKUP_DATABASES=${BACKUP_DATABASES}

# Backup schedule
${BACKUP_SCHEDULE} root /scripts/backup-databases.sh >> /var/log/backup.log 2>&1

# Empty line required at end of crontab
EOF

# Set proper permissions
chmod 0644 "${CRONTAB_FILE}"

# Load crontab
crontab "${CRONTAB_FILE}"

# Create log file
touch /var/log/backup.log

echo "[$(date)] Backup service initialized successfully"
echo "[$(date)] Backup schedule: ${BACKUP_SCHEDULE}"
echo "[$(date)] Backup retention: ${BACKUP_RETENTION_DAYS} days"
echo "[$(date)] Databases to backup: ${BACKUP_DATABASES}"
echo "[$(date)] Starting cron daemon..."

# Start cron in foreground and tail the log
cron && tail -f /var/log/backup.log
