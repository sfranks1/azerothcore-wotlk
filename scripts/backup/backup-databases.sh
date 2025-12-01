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
BACKUP_KEEP_WEEKLY="${BACKUP_KEEP_WEEKLY:-false}"
BACKUP_WEEKLY_DAY="${BACKUP_WEEKLY_DAY:-0}"

# Databases to backup
DATABASES="${BACKUP_DATABASES:-acore_auth acore_world acore_characters acore_playerbots}"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Generate timestamp for backup files
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DATE=$(date +%Y-%m-%d)
DAY_OF_WEEK=$(date +%u)

# Determine if this is a weekly backup
# Day of week: 1=Monday, 7=Sunday (using %u)
# BACKUP_WEEKLY_DAY: 0=Sunday, 1=Monday, etc. (convert to match)
WEEKLY_DAY_CONVERTED=$((BACKUP_WEEKLY_DAY == 0 ? 7 : BACKUP_WEEKLY_DAY))
IS_WEEKLY="false"
WEEKLY_SUFFIX=""

echo "[$(date)] Today is day ${DAY_OF_WEEK} of the week"
echo "[$(date)] Configured weekly backup day is ${WEEKLY_DAY_CONVERTED}"

if [ "${BACKUP_KEEP_WEEKLY}" = "true" ] && [ "${DAY_OF_WEEK}" = "${WEEKLY_DAY_CONVERTED}" ]; then
    IS_WEEKLY="true"
    WEEKLY_SUFFIX="-weekly"
    echo "[$(date)] This is a WEEKLY backup (will be kept longer)"
fi

echo "[$(date)] Starting database backup..."

# Backup each database
for DB in $DATABASES; do
    echo "[$(date)] Backing up database: ${DB}"

    BACKUP_FILE="${BACKUP_DIR}/${DB}_${TIMESTAMP}${WEEKLY_SUFFIX}.sql.gz"

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

# Run cleanup script
if [ -x "/scripts/cleanup-backups.sh" ]; then
    /scripts/cleanup-backups.sh
else
    echo "[$(date)] Warning: cleanup-backups.sh not found or not executable"
fi

echo "[$(date)] Backup process completed successfully"
