# MySQL SSL Certificate Generation Script
# Run this in PowerShell from the mysql-ssl directory

Set-Location $PSScriptRoot

Write-Host "Cleaning up old certificates..." -ForegroundColor Yellow
Remove-Item *.pem -ErrorAction SilentlyContinue

Write-Host "`nGenerating CA certificate..." -ForegroundColor Cyan
& openssl genrsa 2048 | Out-File -Encoding ASCII ca-key.pem
& openssl req -new -x509 -nodes -days 3650 -key ca-key.pem -out ca-cert.pem -subj "/CN=MySQL_CA"

Write-Host "`nGenerating server certificate..." -ForegroundColor Cyan
& openssl req -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-req.pem -subj "/CN=ac-database"
& openssl rsa -in server-key.pem -out server-key.pem
& openssl x509 -req -in server-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem

Write-Host "`nGenerating client certificate..." -ForegroundColor Cyan
& openssl req -newkey rsa:2048 -days 3650 -nodes -keyout client-key.pem -out client-req.pem -subj "/CN=django_client"
& openssl rsa -in client-key.pem -out client-key.pem
& openssl x509 -req -in client-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 02 -out client-cert.pem

Write-Host "`nVerifying certificates..." -ForegroundColor Cyan
& openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem

Write-Host "`nCleaning up temporary files..." -ForegroundColor Yellow
Remove-Item *-req.pem -ErrorAction SilentlyContinue

Write-Host "`nGenerated certificates:" -ForegroundColor Green
Get-ChildItem *.pem | Format-Table Name, Length, LastWriteTime

Write-Host "`nDone! Certificates generated successfully." -ForegroundColor Green
