# Create Windows package script
$packageDir = "integrity-assistant-windows"
$outputZip = "public/downloads/integrity-assistant-windows.zip"

# Create package directory
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null

# Copy files
Copy-Item "public/downloads/run_integrity.bat" $packageDir
Copy-Item "public/downloads/IMPORTANT_README.txt" $packageDir
Copy-Item "src/integrity_*.py" $packageDir

# Create config directory
New-Item -ItemType Directory -Path "$packageDir/config" -Force | Out-Null

# Create ZIP file
Compress-Archive -Path "$packageDir/*" -DestinationPath $outputZip -Force

# Clean up
Remove-Item -Path $packageDir -Recurse -Force

Write-Host "Windows package created successfully: $outputZip" 