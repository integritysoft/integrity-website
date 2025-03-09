Write-Host "=== Creating Integrity Assistant Windows Package ===" -ForegroundColor Cyan

$packageDir = "integrity-assistant-windows"
$outputZip = "public/downloads/integrity-assistant-windows.zip"

# Create package directory structure
Write-Host "Creating package structure..." -ForegroundColor White
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
New-Item -ItemType Directory -Path "$packageDir/src" -Force | Out-Null
New-Item -ItemType Directory -Path "$packageDir/config" -Force | Out-Null

# Create requirements.txt
Write-Host "Creating requirements.txt..." -ForegroundColor White
@"
requests==2.31.0
customtkinter==5.2.0
numpy==1.26.0
opencv-python==4.8.0
Pillow==10.0.0
easyocr==1.7.1
"@ | Out-File -FilePath "$packageDir/src/requirements.txt" -Encoding utf8

# Copy main files
Write-Host "Copying main files..." -ForegroundColor White
Copy-Item "public/downloads/run_integrity.bat" -Destination "$packageDir/run_integrity.bat"
Copy-Item "public/downloads/IMPORTANT_README.txt" -Destination "$packageDir/IMPORTANT_README.txt"

# Copy source files
Write-Host "Copying source files..." -ForegroundColor White
Copy-Item "src/integrity_*.py" -Destination "$packageDir/src/"

# Create ZIP file
Write-Host "Creating ZIP archive..." -ForegroundColor White
Compress-Archive -Path "$packageDir/*" -DestinationPath $outputZip -Force

# Clean up
Write-Host "Cleaning up..." -ForegroundColor White
Remove-Item -Path $packageDir -Recurse -Force

Write-Host "Package created successfully: $outputZip" -ForegroundColor Green 