#!/bin/bash

# AzerothCore Database Backup Cleanup Script
# This script manages backup retention and cleanup

set -e

# Configuration from environment variables
BACKUP_DIR="${BACKUP_DIR:-/backups}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
BACKUP_KEEP_WEEKLY="${BACKUP_KEEP_WEEKLY:-false}"
BACKUP_WEEKLY_RETENTION_DAYS="${BACKUP_WEEKLY_RETENTION_DAYS:-30}"

echo "[$(date)] Starting backup cleanup..."
echo "[$(date)] Backup directory: ${BACKUP_DIR}"
echo "[$(date)] Daily retention: ${BACKUP_RETENTION_DAYS} days"
echo "[$(date)] Keep weekly backups: ${BACKUP_KEEP_WEEKLY}"

# Clean up daily backups older than retention period
if [ "${BACKUP_RETENTION_DAYS}" -gt 0 ]; then
    echo "[$(date)] Cleaning up daily backups older than ${BACKUP_RETENTION_DAYS} days..."

    # Find and delete daily backups (not marked as weekly)
    DELETED_COUNT=$(find "${BACKUP_DIR}" -name "*.sql.gz" -type f -mtime +${BACKUP_RETENTION_DAYS} ! -name "*-weekly.sql.gz" -delete -print | wc -l)

    if [ "${DELETED_COUNT}" -gt 0 ]; then
        echo "[$(date)] Deleted ${DELETED_COUNT} old daily backup(s)"
    else
        echo "[$(date)] No old daily backups to delete"
    fi
else
    echo "[$(date)] Daily backup cleanup disabled (retention set to 0)"
fi

# Clean up weekly backups if enabled
if [ "${BACKUP_KEEP_WEEKLY}" = "true" ]; then
    if [ "${BACKUP_WEEKLY_RETENTION_DAYS}" -gt 0 ]; then
        echo "[$(date)] Cleaning up weekly backups older than ${BACKUP_WEEKLY_RETENTION_DAYS} days..."

        DELETED_WEEKLY_COUNT=$(find "${BACKUP_DIR}" -name "*-weekly.sql.gz" -type f -mtime +${BACKUP_WEEKLY_RETENTION_DAYS} -delete -print | wc -l)

        if [ "${DELETED_WEEKLY_COUNT}" -gt 0 ]; then
            echo "[$(date)] Deleted ${DELETED_WEEKLY_COUNT} old weekly backup(s)"
        else
            echo "[$(date)] No old weekly backups to delete"
        fi
    else
        echo "[$(date)] Weekly backup cleanup disabled - keeping all weekly backups indefinitely"
    fi
fi

# Display current backup statistics
DAILY_BACKUPS=$(find "${BACKUP_DIR}" -name "*.sql.gz" -type f ! -name "*-weekly.sql.gz" 2>/dev/null | wc -l)
WEEKLY_BACKUPS=$(find "${BACKUP_DIR}" -name "*-weekly.sql.gz" -type f 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "${BACKUP_DIR}" 2>/dev/null | cut -f1)

echo "[$(date)] Current backup statistics:"
echo "[$(date)]   Daily backups: ${DAILY_BACKUPS}"
echo "[$(date)]   Weekly backups: ${WEEKLY_BACKUPS}"
echo "[$(date)]   Total size: ${TOTAL_SIZE}"
echo "[$(date)] Cleanup complete"
