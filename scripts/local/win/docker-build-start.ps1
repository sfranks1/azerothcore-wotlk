# Runs docker compose build, starts server, attaches in new terminal window
# Run from repo root

# Build Docker images
& "$PSScriptRoot\docker-build.ps1"
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

# Start server
& "$PSScriptRoot\docker-start.ps1"
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}