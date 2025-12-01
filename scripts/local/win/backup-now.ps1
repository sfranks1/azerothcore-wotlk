# Manual Database Backup Script
# Runs the backup immediately and logs output to backup.log

Write-Host "Running manual database backup..." -ForegroundColor Cyan
Write-Host ""

# Run backup with output to both console and log file
docker exec ac-backup-cron bash -c "/scripts/backup-databases.sh 2>&1 | tee -a /azerothcore/logs/backup.log"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Backup completed successfully!" -ForegroundColor Green
    Write-Host "Backups location: .\data\sql\ac-backups\" -ForegroundColor Gray
    Write-Host "Log file: .\env\dist\logs\backup.log" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "Backup failed with exit code: $LASTEXITCODE" -ForegroundColor Red
}
