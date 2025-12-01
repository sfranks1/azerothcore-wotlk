# Silent Database Backup Script
# Runs the backup in the background, output only goes to backup.log

Write-Host "Running database backup in background..." -ForegroundColor Cyan
Write-Host "Check .\env\dist\logs\backup.log for progress" -ForegroundColor Gray
Write-Host ""

# Run backup with output only to log file
docker exec ac-backup-cron bash -c "/scripts/backup-databases.sh >> /azerothcore/logs/backup.log 2>&1"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Backup completed successfully!" -ForegroundColor Green
    Write-Host "Backups location: .\data\sql\ac-backups\" -ForegroundColor Gray
    Write-Host "Log file: .\env\dist\logs\backup.log" -ForegroundColor Gray
} else {
    Write-Host "Backup failed with exit code: $LASTEXITCODE" -ForegroundColor Red
}
