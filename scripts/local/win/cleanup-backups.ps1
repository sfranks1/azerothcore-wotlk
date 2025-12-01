# Manual Backup Cleanup Script
# Runs the cleanup script to remove old backups based on retention settings

Write-Host "Running backup cleanup..." -ForegroundColor Cyan
Write-Host ""

# Run cleanup with output to both console and log file
docker exec ac-backup-cron bash -c "/scripts/cleanup-backups.sh 2>&1 | tee -a /azerothcore/logs/backup.log"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Cleanup completed successfully!" -ForegroundColor Green
    Write-Host "Backups location: .\data\sql\ac-backups\" -ForegroundColor Gray
    Write-Host "Log file: .\env\dist\logs\backup.log" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "Cleanup failed with exit code: $LASTEXITCODE" -ForegroundColor Red
}
