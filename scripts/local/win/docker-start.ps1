# Starts Docker containers and attaches to worldserver in new terminal window
# Run from repo root

Write-Host "Starting server..." -ForegroundColor Cyan
docker compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start Docker containers!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Server started successfully!" -ForegroundColor Green
Write-Host "Attaching to worldserver in new terminal window..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "docker attach ac-worldserver"
