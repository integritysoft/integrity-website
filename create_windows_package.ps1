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
Pillow==10.2.0
easyocr==1.7.1
python-dateutil==2.8.2
"@ | Out-File -FilePath "$packageDir/src/requirements.txt" -Encoding utf8

# Copy main files
Write-Host "Copying main files..." -ForegroundColor White
Copy-Item "public/downloads/run_integrity.bat" -Destination "$packageDir/run_integrity.bat"
Copy-Item "public/downloads/IMPORTANT_README.txt" -Destination "$packageDir/IMPORTANT_README.txt"
Copy-Item "public/downloads/install.bat" -Destination "$packageDir/install.bat"

# Copy source files
Write-Host "Copying source files..." -ForegroundColor White
Copy-Item "src/integrity_*.py" -Destination "$packageDir/src/"

# Create verify_helpers.py
Write-Host "Creating verification helpers..." -ForegroundColor White
@"
def check_imports(packages):
    failed = []
    for package in packages:
        try:
            if package == 'cv2':
                import cv2
            elif package == 'PIL':
                from PIL import ImageGrab
            else:
                __import__(package)
        except ImportError:
            failed.append(package)
    return failed
"@ | Out-File -FilePath "$packageDir/src/verify_helpers.py" -Encoding utf8

# Create ZIP file
Write-Host "Creating ZIP archive..." -ForegroundColor White
Compress-Archive -Path "$packageDir/*" -DestinationPath $outputZip -Force

# Clean up
Write-Host "Cleaning up..." -ForegroundColor White
Remove-Item -Path $packageDir -Recurse -Force

Write-Host "Package created successfully: $outputZip" -ForegroundColor Green 