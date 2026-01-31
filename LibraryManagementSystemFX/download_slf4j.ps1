# Run this once to download SLF4J JARs required by SQLite JDBC.
# Right-click -> Run with PowerShell, or: powershell -ExecutionPolicy Bypass -File download_slf4j.ps1

$lib = "$PSScriptRoot\lib"
if (-not (Test-Path $lib)) { New-Item -ItemType Directory -Path $lib -Force | Out-Null }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$urls = @{
    "slf4j-api-1.7.36.jar"    = "https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.36/slf4j-api-1.7.36.jar"
    "slf4j-nop-1.7.36.jar"    = "https://repo1.maven.org/maven2/org/slf4j/slf4j-nop/1.7.36/slf4j-nop-1.7.36.jar"
}

foreach ($name in $urls.Keys) {
    $path = Join-Path $lib $name
    if (Test-Path $path) { Write-Host "OK (already exists): $name"; continue }
    Write-Host "Downloading $name..."
    try {
        Invoke-WebRequest -Uri $urls[$name] -OutFile $path -UseBasicParsing
        Write-Host "OK: $name"
    } catch {
        Write-Host "FAILED: $name - $($_.Exception.Message)"
        Write-Host "Download manually from: $($urls[$name])"
    }
}
Write-Host "Done. Rebuild and run the app."
