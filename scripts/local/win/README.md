# Windows PowerShell Scripts

Local helper scripts for Windows users.

## Database Backup Scripts

### backup-now.ps1
Runs a manual database backup immediately, showing output on screen AND logging to file.

**Usage:**
```powershell
.\scripts\local\win\backup-now.ps1
```

**Features:**
- Shows backup progress in real-time
- Logs output to `env/dist/logs/backup.log`
- Displays success/failure message
- Shows backup and log locations

### backup-silent.ps1
Runs a backup silently in the background, output only goes to log file.

**Usage:**
```powershell
.\scripts\local\win\backup-silent.ps1
```

**Features:**
- Quiet operation
- All output logged to `env/dist/logs/backup.log`
- Displays only completion status

### cleanup-backups.ps1
Manually runs the backup cleanup process to remove old backups.

**Usage:**
```powershell
.\scripts\local\win\cleanup-backups.ps1
```

**Features:**
- Removes daily backups older than configured retention period
- Manages weekly backup retention (if enabled)
- Shows cleanup statistics
- Logs output to `env/dist/logs/backup.log`

## Notes

- Make sure Docker Desktop is running before executing these scripts
- The `ac-backup-cron` container must be running
- Backups are saved to: `data/sql/ac-backups/`
- Logs are saved to: `env/dist/logs/backup.log`

## Backup Retention

Configure retention settings in your `.env` file:
- `BACKUP_RETENTION_DAYS` - How many days to keep daily backups (default: 7)
- `BACKUP_KEEP_WEEKLY` - Enable weekly backup retention (default: false)
- `BACKUP_WEEKLY_RETENTION_DAYS` - How many days to keep weekly backups (default: 30, 0 = forever)
- `BACKUP_WEEKLY_DAY` - Day of week for weekly backups (0=Sunday, 1=Monday, etc.)
