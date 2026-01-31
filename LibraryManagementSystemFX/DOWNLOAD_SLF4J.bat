@echo off
echo Downloading SLF4J JARs (required by SQLite JDBC)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_slf4j.ps1"
pause
