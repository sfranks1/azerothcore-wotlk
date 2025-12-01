-- Create backup user for database backups
-- This script creates a dedicated user with minimal privileges needed for backups

-- Drop user if exists (MySQL 8.0+)
DROP USER IF EXISTS 'backup'@'%';

-- Create the backup user
-- Password will be set via environment variable in initialization
CREATE USER 'backup'@'%' IDENTIFIED BY 'BACKUP_PASSWORD_PLACEHOLDER';

-- Grant necessary privileges for mysqldump
-- LOCK TABLES: Required for consistent backups
-- SELECT: Required to read data
-- SHOW VIEW: Required to dump views
-- RELOAD: Required for certain backup operations
-- REPLICATION CLIENT: Required for --master-data option if needed
-- EVENT: Required to dump events
-- TRIGGER: Required to dump triggers
-- PROCESS: Required to dump tablespaces
GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER, PROCESS ON *.* TO 'backup'@'%';

-- Apply privileges
FLUSH PRIVILEGES;
