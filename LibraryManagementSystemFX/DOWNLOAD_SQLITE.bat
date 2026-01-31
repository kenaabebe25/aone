@echo off
cd /d "%~dp0lib"
echo Downloading sqlite-jdbc 3.43.1.0 (no SLF4J needed)...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.43.1.0/sqlite-jdbc-3.43.1.0.jar' -OutFile 'sqlite-jdbc-3.43.1.0.jar' -UseBasicParsing; if (Test-Path 'sqlite-jdbc-3.43.1.0.jar') { Write-Host 'OK. Rebuild and run the app.' } else { Write-Host 'Failed. Download manually from: https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.43.1.0/sqlite-jdbc-3.43.1.0.jar' }"
pause
