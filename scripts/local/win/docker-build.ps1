# Builds Docker images with logging
# Run from repo root

#create logs directory if it doesn't exist
$logDir = "./scripts/logs"
if (!(Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

Write-Host "Building Docker images..." -ForegroundColor Cyan
docker compose build > ./scripts/logs/docker-build.log 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed! Check ./scripts/logs/docker-build.log for details." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "Docker images built successfully!" -ForegroundColor Green
