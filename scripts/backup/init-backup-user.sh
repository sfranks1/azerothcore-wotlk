#!/bin/bash

# Initialize backup user in the database
# This script replaces the password placeholder and creates the backup user

set -e

DB_HOST="${DB_HOST:-ac-database}"
DB_PORT="${DB_PORT:-3306}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-password}"
BACKUP_USER="${BACKUP_USER:-backup}"
BACKUP_PASSWORD="${BACKUP_PASSWORD:-backup_password}"

echo "[$(date)] Waiting for database to be ready..."

# Wait for database to be ready
until mysql -h"${DB_HOST}" -P"${DB_PORT}" -uroot -p"${DB_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    echo "[$(date)] Database not ready, waiting..."
    sleep 2
done

echo "[$(date)] Database is ready, creating backup user..."

# Create temporary SQL file with actual password
TEMP_SQL=$(mktemp)
sed "s/BACKUP_PASSWORD_PLACEHOLDER/${BACKUP_PASSWORD}/g" /scripts/create-backup-user.sql > "${TEMP_SQL}"

# Execute SQL to create backup user
if mysql -h"${DB_HOST}" -P"${DB_PORT}" -uroot -p"${DB_ROOT_PASSWORD}" < "${TEMP_SQL}"; then
    echo "[$(date)] Backup user '${BACKUP_USER}' created successfully"
else
    echo "[$(date)] ERROR: Failed to create backup user" >&2
    rm -f "${TEMP_SQL}"
    exit 1
fi

# Clean up
rm -f "${TEMP_SQL}"

echo "[$(date)] Backup user initialization complete"
