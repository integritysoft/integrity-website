# Create package script for Integrity Assistant
$packageDir = "package-template"
$outputZip = "integrity-assistant.zip"

# Ensure we're in the right directory
if (-not (Test-Path $packageDir)) {
    Write-Error "Package template directory not found!"
    exit 1
}

# Create temporary directory for packaging
$tempDir = "temp_package"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Copy required files
Copy-Item "$packageDir\install.bat" $tempDir
Copy-Item "$packageDir\IMPORTANT_README.txt" $tempDir
Copy-Item -Path "$packageDir\src" -Destination "$tempDir\src" -Recurse

# Create the ZIP file
Compress-Archive -Path "$tempDir\*" -DestinationPath $outputZip -Force

# Clean up
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "Package created successfully: $outputZip" 