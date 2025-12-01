#!/bin/bash

# AzerothCore Database Backup Script
# This script backs up all AzerothCore databases using mysqldump

set -e

# Configuration from environment variables
DB_HOST="${DB_HOST:-ac-database}"
DB_PORT="${DB_PORT:-3306}"
BACKUP_USER="${BACKUP_USER:-backup}"
BACKUP_PASSWORD="${BACKUP_PASSWORD:-backup_password}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"

# Databases to backup
DATABASES="${BACKUP_DATABASES:-acore_auth acore_world acore_characters acore_playerbots}"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Generate timestamp for backup files
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DATE=$(date +%Y-%m-%d)

echo "[$(date)] Starting database backup..."

# Backup each database
for DB in $DATABASES; do
    echo "[$(date)] Backing up database: ${DB}"

    BACKUP_FILE="${BACKUP_DIR}/${DB}_${TIMESTAMP}.sql.gz"

    # Perform backup with compression
    if mysqldump \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --user="${BACKUP_USER}" \
        --password="${BACKUP_PASSWORD}" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --opt \
        "${DB}" | gzip > "${BACKUP_FILE}"; then

        echo "[$(date)] Successfully backed up ${DB} to ${BACKUP_FILE}"

        # Get file size for logging
        SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
        echo "[$(date)] Backup size: ${SIZE}"
    else
        echo "[$(date)] ERROR: Failed to backup ${DB}" >&2
        exit 1
    fi
done

# Clean up old backups
if [ "${BACKUP_RETENTION_DAYS}" -gt 0 ]; then
    echo "[$(date)] Cleaning up backups older than ${BACKUP_RETENTION_DAYS} days..."

    find "${BACKUP_DIR}" -name "*.sql.gz" -type f -mtime +${BACKUP_RETENTION_DAYS} -delete

    echo "[$(date)] Cleanup complete"
fi

echo "[$(date)] Backup process completed successfully"
