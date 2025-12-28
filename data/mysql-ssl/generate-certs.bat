@echo off
REM Generate MySQL SSL Certificates for Docker

cd /d "%~dp0"

echo Generating CA certificate...
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 3650 -key ca-key.pem -out ca-cert.pem -subj "//CN=MySQL_CA"

echo Generating server certificate...
openssl req -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-req.pem -subj "//CN=ac-database"
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem

echo Generating client certificate...
openssl req -newkey rsa:2048 -days 3650 -nodes -keyout client-key.pem -out client-req.pem -subj "//CN=django_client"
openssl rsa -in client-key.pem -out client-key.pem
openssl x509 -req -in client-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 02 -out client-cert.pem

echo Verifying certificates...
openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem

echo.
echo Certificates generated successfully!
echo.
dir *.pem
