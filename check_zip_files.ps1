# PowerShell script to check and prepare download files

Write-Host "=== INTEGRITY WEBSITE DOWNLOAD FILES CHECK ===" -ForegroundColor Cyan
Write-Host "This script will check the download files and prepare them for distribution." -ForegroundColor White
Write-Host ""

# Check if 7-Zip is installed
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (-not (Test-Path $7zipPath)) {
    Write-Host "7-Zip is not installed in the standard location." -ForegroundColor Yellow
    Write-Host "Please install 7-Zip from https://7-zip.org/ to create password-protected files." -ForegroundColor Yellow
    Write-Host ""
}

# Check if the public/downloads directory exists
$downloadsDir = "public\downloads"
if (-not (Test-Path $downloadsDir)) {
    Write-Host "ERROR: $downloadsDir directory not found." -ForegroundColor Red
    exit 1
}

# Check each platform's zip file
$platforms = @("windows", "macos", "linux")
$password = "integrity2025"

foreach ($platform in $platforms) {
    $originalFile = "$downloadsDir\integrity-assistant-$platform.zip"
    $protectedFile = "$downloadsDir\integrity-assistant-$platform-protected.zip"
    
    # Check if original file exists
    if (-not (Test-Path $originalFile)) {
        Write-Host "WARNING: $originalFile not found." -ForegroundColor Yellow
        continue
    }
    
    # Check if it's already protected (simple check, not foolproof)
    $fileContent = Get-Content $originalFile -Raw -Encoding Byte
    $isProtected = $false
    
    # This is a very simple heuristic - zip files with password typically have this signature
    if ($fileContent -ne $null) {
        $isProtected = [System.Text.Encoding]::ASCII.GetString($fileContent[0..100]) -match "encrypted"
    }
    
    Write-Host "File: $originalFile" -ForegroundColor Cyan
    if ($isProtected) {
        Write-Host "  Status: Already password-protected" -ForegroundColor Green
    } else {
        Write-Host "  Status: Not password-protected" -ForegroundColor Yellow
    }
    
    # Check if protected name file already exists
    if (Test-Path $protectedFile) {
        Write-Host "  Protected file already exists at: $protectedFile" -ForegroundColor Green
    } else {
        Write-Host "  Need to create protected file: $protectedFile" -ForegroundColor Yellow
        
        if (Test-Path $7zipPath) {
            Write-Host "  Creating protected file with 7-Zip..." -ForegroundColor White
            
            # Create a directory to hold the contents
            $tempDir = "temp_$platform"
            if (Test-Path $tempDir) { Remove-Item -Path $tempDir -Recurse -Force }
            New-Item -Path $tempDir -ItemType Directory | Out-Null
            
            # Extract the original zip
            & $7zipPath x -o"$tempDir" "$originalFile" | Out-Null
            
            # Package with password protection
            & $7zipPath a -tzip "$protectedFile" "$tempDir\*" -p"$password" -mem=AES256 | Out-Null
            
            # Clean up
            Remove-Item -Path $tempDir -Recurse -Force
            
            Write-Host "  Created password-protected file: $protectedFile" -ForegroundColor Green
        } else {
            Write-Host "  Cannot create protected file without 7-Zip." -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

# Check if HTML points to the right files
$htmlFile = "index.html"
if (Test-Path $htmlFile) {
    $htmlContent = Get-Content $htmlFile -Raw
    
    foreach ($platform in $platforms) {
        $expectedLink = "/downloads/integrity-assistant-$platform.zip"
        $protectedLink = "/downloads/integrity-assistant-$platform-protected.zip"
        
        if ($htmlContent -match [regex]::Escape($expectedLink)) {
            Write-Host "HTML contains link to: $expectedLink" -ForegroundColor Green
        } elseif ($htmlContent -match [regex]::Escape($protectedLink)) {
            Write-Host "HTML contains link to: $protectedLink" -ForegroundColor Green
            Write-Host "  Make sure this file exists in $downloadsDir" -ForegroundColor Yellow
        } else {
            Write-Host "WARNING: HTML does not contain expected links for $platform" -ForegroundColor Red
        }
    }
} else {
    Write-Host "WARNING: $htmlFile not found. Could not check HTML links." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Download files check complete!" -ForegroundColor Cyan
Write-Host "Please ensure all files exist at the locations specified in your HTML links." -ForegroundColor White 